#!/bin/bash

# --- BẠN HÃY ĐIỀN 2 THÔNG TIN DƯỚI ĐÂY ---
AWS_ACCESS_KEY_ID="DIEN_ACCESS_KEY_CUA_BAN_VAO_DAY"
AWS_SECRET_ACCESS_KEY="DIEN_SECRET_KEY_CUA_BAN_VAO_DAY"
# ----------------------------------------

IP_EC2="3.26.73.187"
KEY_PATH="$HOME/Downloads/income-key.pem"
BUCKET_NAME="bucket-nduong-track2-day21"

if [ ! -f "$KEY_PATH" ]; then
    echo "Lỗi: Không tìm thấy file $KEY_PATH. Đảm bảo file đang nằm ở mục Downloads."
    exit 1
fi

chmod 400 "$KEY_PATH"

echo "Đang upload code lên EC2..."
scp -o StrictHostKeyChecking=no -i "$KEY_PATH" src/serve.py ubuntu@$IP_EC2:~/

echo "Đang cấu hình máy chủ EC2 (Có thể mất 2-3 phút để cài thư viện)..."
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@$IP_EC2 << EOF
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y python3-pip
    pip3 install fastapi uvicorn scikit-learn joblib boto3 --break-system-packages
    
    mkdir -p ~/models ~/src
    mv ~/serve.py ~/src/serve.py

    if [ ! -f ~/.ssh/income_deploy ]; then
        ssh-keygen -t ed25519 -f ~/.ssh/income_deploy -N "" -C "github-actions-deploy"
        cat ~/.ssh/income_deploy.pub >> ~/.ssh/authorized_keys
    fi

    cat << 'SVC' | sudo tee /etc/systemd/system/income-api.service > /dev/null
[Unit]
Description=Income Model Inference Server
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu
Environment="ARTIFACT_BUCKET=$BUCKET_NAME"
Environment="AWS_DEFAULT_REGION=ap-southeast-2"
Environment="AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
Environment="AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"
ExecStart=/usr/bin/python3 /home/ubuntu/src/serve.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SVC

    sudo systemctl daemon-reload
    sudo systemctl enable income-api

    echo -e "\n\n======================================================="
    echo "ĐÃ CẤU HÌNH XONG! DƯỚI ĐÂY LÀ PRIVATE KEY CỦA BẠN:"
    echo "Hãy copy TOÀN BỘ từ -----BEGIN... đến hết ...KEY-----"
    echo "======================================================="
    cat ~/.ssh/income_deploy
EOF
