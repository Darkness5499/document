| Thư mục                   | Mô tả                                                                  | Khi nào bạn dùng                            |
| ------------------------- | ---------------------------------------------------------------------- | ------------------------------------------- |
| `/`                       | Root directory — “gốc” của toàn bộ hệ thống.                           | Không nên thao tác trực tiếp.               |
| `/bin`                    | Chứa **lệnh cơ bản** cho mọi user, như `ls`, `cp`, `mv`, `bash`.       | Lệnh cần có khi boot hệ thống.              |
| `/sbin`                   | Lệnh dành cho **system admin**, như `reboot`, `ifconfig`.              | Lệnh quản trị hệ thống.                     |
| `/usr`                    | “User System Resources” — nơi chứa hầu hết chương trình cài thêm.      | Rất quan trọng — chi tiết ở dưới.           |
| `/usr/bin`                | Chứa **các chương trình người dùng** (như `git`, `kubectl`, `python`). | Khi bạn cài tool toàn hệ thống.             |
| `/usr/sbin`               | Các lệnh admin cấp hệ thống (ví dụ `sshd`, `apache2`).                 | Dành cho service/system-level.              |
| `/usr/local`              | Dành cho **các phần mềm tự cài thủ công** (không phải của OS).         | Homebrew thường đặt ở đây.                  |
| `/usr/share`              | Chứa dữ liệu **không phụ thuộc kiến trúc** (docs, icons, templates).   | Nếu app có tài nguyên tĩnh.                 |
| `/lib` hoặc `/usr/lib`    | Chứa **thư viện (library)** mà các binary cần để chạy.                 | File `.so` trên Linux, `.dylib` trên macOS. |
| `/etc`                    | Chứa **file cấu hình hệ thống**, ví dụ `hosts`, `ssh/sshd_config`.     | Config toàn hệ thống.                       |
| `/var`                    | “Variable” — dữ liệu thay đổi thường xuyên (log, cache, spool).        | Log, file tạm, PID.                         |
| `/var/log`                | Chứa file log của system & app.                                        | Log nginx, syslog, kubectl,...              |
| `/tmp`                    | File tạm thời (sẽ bị xóa sau reboot).                                  | File tạm của app.                           |
| `/home`                   | Thư mục người dùng.                                                    | `/home/alex` chẳng hạn.                     |
| `/root`                   | Thư mục riêng của user root.                                           | Khi login bằng root.                        |
| `/opt`                    | Dành cho **ứng dụng bên thứ ba lớn** (Oracle, Chrome, VS Code...).     | App tự chứa file riêng.                     |
| `/dev`                    | Đại diện cho **thiết bị phần cứng** (ổ đĩa, USB, terminal...).         | Ít khi thao tác trực tiếp.                  |
| `/mnt` hoặc `/media`      | Dùng để **mount ổ đĩa hoặc thiết bị ngoài**.                           | Mount volume, USB, NFS.                     |
| `/Applications` *(macOS)* | App GUI (Visual Studio Code, Chrome, Docker Desktop, v.v.).            | Khi bạn cài app qua `.pkg` hoặc App Store.  |


