যদি আপনার **SSH access** থাকে, তাহলে নিচের commandগুলো একে একে paste করতে পারেন। এগুলো **কিছু delete করবে না**, শুধু system audit করবে এবং suspicious file খুঁজে বের করবে।

> **প্রথমে project root-এ যান** (যেখানে `artisan` ফাইল আছে)।

```bash
cd /path/to/your/laravel/project
pwd
ls -la
```

---

## 1. গত ৩০ দিনে modified files

```bash
find . -type f -mtime -30 | sort
```

---

## 2. Suspicious PHP files

```bash
find . -type f -name "*.php" | grep -Ei "(shell|cmd|upload|backdoor|cache|test|admin|file|x|z|1)\.php"
```

---

## 3. uploads/storage/images-এর ভিতরে PHP file আছে কিনা

```bash
find . \( -path "./storage/*" -o -path "./public/uploads/*" -o -path "./public/images/*" -o -path "./tmp/*" \) -type f -name "*.php"
```

---

## 4. Dangerous PHP functions search

```bash
grep -RniE "eval\s*\(|base64_decode\s*\(|gzinflate\s*\(|shell_exec\s*\(|system\s*\(|exec\s*\(|passthru\s*\(|assert\s*\(" .
```

---

## 5. Hidden files

```bash
find . -name ".*" -type f
```

---

## 6. Recently created files (last 30 days)

```bash
find . -type f -ctime -30
```

---

## 7. Permission check

```bash
find . -type d -perm -777
find . -type f -perm -777
```

---

## 8. Check .htaccess files

```bash
find . -name ".htaccess" -exec ls -l {} \;
```

---

## 9. Check cron jobs (if available)

```bash
crontab -l
```

---

## 10. Check current PHP processes

```bash
ps aux | grep php
```

---

# যদি Malware পাওয়া যায়, **এখনই delete করবেন না।**

আগে নিচের command দিয়ে report তৈরি করুন:

```bash
mkdir -p ~/security_audit

find . -type f -mtime -30 > ~/security_audit/recent_files.txt

grep -RniE "eval\s*\(|base64_decode\s*\(|gzinflate\s*\(|shell_exec\s*\(|system\s*\(|exec\s*\(|passthru\s*\(|assert\s*\(" . > ~/security_audit/suspicious_code.txt 2>/dev/null

find . -type f -name "*.php" > ~/security_audit/all_php_files.txt
```

এরপর এই তিনটি report-এর output (বা file content) আমাকে দিন। আমি লাইন ধরে বিশ্লেষণ করে বলব:

* কোন file আসল Laravel-এর,
* কোন file malware/backdoor,
* কোনগুলো নিরাপদে delete করা যাবে,
* এবং কীভাবে project পুরোপুরি clean করবেন।
