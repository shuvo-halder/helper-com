ভালো খবর। **দুটো `.htaccess`-এই আপাতদৃষ্টিতে malware বা casino redirect-এর কোনো লক্ষণ নেই।** এগুলো Laravel-এর স্বাভাবিক rewrite rules-এর মতোই দেখাচ্ছে।

এখন খুব সম্ভবত নিচের যেকোনো একটি কারণে hack হচ্ছে:

1. `public/index.php` modified হয়েছে।
2. Root `index.php` modified হয়েছে (যদি থাকে)।
3. `public/uploads/`, `storage/`, `images/`-এ webshell আছে।
4. `.user.ini` বা `php.ini` দিয়ে auto_prepend_file ব্যবহার করা হয়েছে।
5. Database-এ malicious content inject করা হয়েছে।
6. Hosting account-এর অন্য কোনো site infected হয়ে cross-account infection হয়েছে।

---

## এখন এই Commandগুলো Run করুন

### 1. public/index.php verify

```bash
sed -n '1,80p' public/index.php
```

---

### 2. Root index.php আছে কিনা

```bash
ls -la | grep index.php
```

যদি থাকে

```bash
sed -n '1,80p' index.php
```

---

### 3. .user.ini

```bash
find . -name ".user.ini" -exec cat {} \;
```

---

### 4. auto_prepend_file খুঁজুন

```bash
grep -R "auto_prepend_file" .
```

---

### 5. Hidden PHP files

```bash
find . -type f -name ".*.php"
```

---

### 6. Base64 malware scan (vendor বাদ দিয়ে)

```bash
grep -Rni --exclude-dir=vendor --exclude-dir=node_modules "base64_decode(" .
```

---

### 7. Eval scan

```bash
grep -Rni --exclude-dir=vendor --exclude-dir=node_modules "eval(" .
```

---

### 8. Files modified in last 7 days

```bash
find . -type f -mtime -7 | sort
```

---

## একটা গুরুত্বপূর্ণ প্রশ্ন

আপনি বলেছিলেন:

> **"link e dhukle casino show kore"**

এটা ঠিক কীভাবে হচ্ছে?

* **A.** সব URL-এ casino page আসে?
* **B.** শুধু Google Search থেকে click করলে casino আসে?
* **C.** শুধু Mobile-এ casino আসে?
* **D.** শুধু প্রথমবার visit করলে redirect হয়?
* **E.** Homepage ঠিক আছে, কিন্তু কিছু random URL-এ casino আসে?

এটার উত্তর খুব গুরুত্বপূর্ণ। যদি **শুধু Google Search থেকে redirect হয়**, তাহলে এটা প্রায়ই **SEO spam / cloaking**-এর লক্ষণ, যেখানে malware সাধারণ visitor-কে নয়, search engine traffic-কে target করে। সেই ক্ষেত্রে `index.php` বা database-এর পাশাপাশি Google index-ও পরীক্ষা করতে হবে।

**পরের ধাপে `public/index.php`-এর প্রথম ৮০ লাইন এবং উপরের commandগুলোর output দিন।** তখন আমরা entry point শনাক্ত করতে পারব।
