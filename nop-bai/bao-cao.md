# Báo Cáo Lab Day 21 - CI/CD cho AI Systems

| | |
|---|---|
| Họ và tên | Nông Ngọc Dương |
| MSSV | 2A202601296 |
| Lớp / Khóa | K4 |
| Repo GitHub | https://github.com/nduong11/test-day21-track2 |
| Ngày nộp | 21/08/2026 |

---

## 1. Bộ Siêu Tham Số Đã Chọn và Lý Do

| Lần chạy | n_estimators | learning_rate | max_depth | f1_score | accuracy |
|---|---|---|---|---|---|
| 1 | 100 | 0.1 | 3 | 0.7109 | 0.8780 |
| 2 | 50 | 0.05 | 2 | 0.6051 | 0.8460 |
| 3 | 200 | 0.1 | 5 | 0.7149 | 0.8740 |

**Bộ siêu tham số đã chọn:** `n_estimators=200`, `learning_rate=0.1`, `max_depth=5`.

**Lý do:** Bộ tham số thứ 3 mang lại giá trị F1-score tốt nhất (0.7149) so với các bộ còn lại và vượt ngưỡng 0.65 yêu cầu của đề bài. Đáng chú ý, lần chạy 1 có accuracy cao nhất (0.8780) nhưng lại có F1 thấp hơn lần 3 (có accuracy 0.8740), cho thấy việc ưu tiên accuracy không đồng nghĩa với mô hình tốt nhất để dự đoán lớp thiểu số. Bên cạnh đó, có một sự đánh đổi khi giảm `learning_rate` ở lần 2: điểm số tụt giảm thảm hại, cho thấy ta cần tăng `n_estimators` và tăng cả `max_depth` để mô hình học được các đặc trưng phức tạp.

---

## 2. Vì Sao Ngưỡng Chất Lượng Đặt Trên F1 Chứ Không Phải Accuracy

Tập dữ liệu Adult Income có đặc tính mất cân bằng lớn: chỉ khoảng 24.8% số người được khảo sát có mức thu nhập cao (>50K). Hệ quả của việc mất cân bằng này là một mô hình giả định đoán toàn bộ người dùng có "thu nhập thấp" vẫn sẽ đạt độ chính xác (accuracy) vào khoảng 0.752. Nhìn bề ngoài thì con số 75.2% có vẻ rất cao, nhưng thực tế mô hình đó là vô dụng vì không thể dự đoán được bất kỳ ai có mức thu nhập > 50K. 

Đó là lý do F1-score (của lớp thu nhập cao) được sử dụng để làm thước đo chất lượng, vì nó là trung bình điều hòa của Precision và Recall, phản ánh chính xác khả năng nhận diện lớp thiểu số của mô hình. Trong bài này, chúng ta không dùng các chế độ trung bình như average="weighted" hay "macro", vì các cách tính này sẽ bị kéo lên bởi độ chính xác cực cao của lớp chiếm đa số, làm mờ đi sai số khi dự đoán lớp thiểu số mà ta đang quan tâm.

---

## 3. Khó Khăn Gặp Phải và Cách Giải Quyết


| Khó khăn | Nguyên nhân | Cách giải quyết |
|---|---|---|
| Đạt ngưỡng F1_score >= 0.65 khá khó | Dữ liệu Adult Income mất cân bằng, mô hình mặc định sẽ thiên về dự đoán lớp đa số. | Thay đổi siêu tham số mạnh hơn (tăng `n_estimators`, `max_depth`) để ép mô hình học tốt hơn, theo dõi trên MLflow. |
| Lỗi khi chạy MLflow (thiếu pkg_resources) | Python 3.12 loại bỏ mặc định setuptools, gây xung đột với thư viện cũ. | Hạ cấp thư viện `setuptools<70` để tương thích ngược. |
| Cấu hình DVC và AWS credentials | Cần phân biệt rõ ràng IAM role, bucket policy và access key. | Thiết lập cẩn thận Secret, dùng IAM user cấp quyền S3 FullAccess (hoặc Read/Write) cho đúng bucket. |

---

## 4. So Sánh Bước 2 và Bước 3 (bắt buộc, 2 - 3 câu)

<!-- Lấy số liệu từ bảng ở mục 3.6 của tasks/buoc-3.md. -->

| | f1_score | accuracy |
|---|---|---|
| Bước 2 (chỉ `train_batch1`) | 0.7149 | 0.8740 |
| Bước 3 (thêm `train_batch2`) | 0.7354 | 0.8820 |

**Nhận xét:** Khi bổ sung thêm dữ liệu mới từ `train_batch2`, kích thước tập huấn luyện tăng gấp đôi (từ 22,361 lên 44,722 dòng) nhưng giữ nguyên phân phối đặc trưng. Kết quả là mô hình đã học được nhiều mẫu dữ liệu hơn, giúp khái quát hóa tốt hơn và đẩy điểm F1_score tăng từ 0.7149 lên 0.7354, đồng thời Accuracy cũng được cải thiện nhẹ. Điều này chứng minh Continuous Training (huấn luyện liên tục) với dữ liệu mới mang lại hiệu quả rõ rệt mà không cần phải tinh chỉnh lại siêu tham số.

---

## 5. Phần Bonus Đã Thực Hiện (nếu có)

<!-- Xóa cả mục 5 nếu không làm bonus. Mỗi bonus tối đa 1 dòng. -->

- [ ] Bonus 1 - Tracking MLflow từ xa với DagsHub: ___
- [ ] Bonus 2 - Điều chỉnh ngưỡng quyết định: ___
- [ ] Bonus 3 - Báo cáo precision / recall tự động: ___
- [ ] Bonus 4 - Hoàn trả về phiên bản trước: ___
- [ ] Bonus 5 - Cảnh báo lệch lạc dữ liệu: ___
