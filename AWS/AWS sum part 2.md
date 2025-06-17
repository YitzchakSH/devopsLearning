<style>*{direction: rtl}</style>

# NETWORKING

### VPC (Virtual Private Cloud) 
- מהווה רשת עצמאית בתוכה יכולים להיות כלל הרכיבים
- 

### Subnet

### Internet Gateway

### Route Table

### Internet Gateway

# load balancer

- לצורך מודליות הופרד יחידת ה-loadBalancer ל-2 חלקים: Targer Group ו-LB

### Target Group

- מכיל קבוצה לוגית של שירותי מחשוב, מתאים ל-LB מסוג מסוים, בהתאם לקינפוג.
- Target - המחשוב שמוכל הקבוצה. יכול להכיל: Lambda, EC2 instance או כתובות private IP.
  - Lambda רק עבור ALB.
- Protocol/Port to connect - הגדרת הצד הפנימי של ה-LB, איך ה-LB מגיע אל השרתים עצמם.
  - HTTP/HTTPS עבור ALB.
  - TCP/UDP עבור NLB.
- Health checks - בדיקה שהשירותים של ה-terget תקינים.
  - בדיקה מלאה עבור ALB.
  - בדיקה של handshake עבור TCP ב-NLB.
- Deregistration Delay - זמן המתנה בין תקשורת אחרונה לניתוק השרת (לצורך שדרוג או מחיקה).
- Stickiness - תקשורת תתבצע לאותו שירות שהחל לתת מענה בעבר.
  - קיים בצורה מלאה ע"י עוגיות עבור ALB בלבד.
  - קיים ברמת IP (מקור, יעד ופורט) עבור NLB.
- Slow Start - הגדלת אחוז התעבורה באופן הדגרתי, עבור שירותים שעומס פתאומי יכול לגרום להם לנפילות
  - קיים עבור ALB בלבד.

### NLB - Network Load Balancer

- LB קלאסי, מהיר, לפניות שאינם מבוססות HTTP
- עובד בשכבה 4, עובד עם פרוטוקולי TCP, TLS, UDP
- מקבל מסנן פניות לפי PORT קבלה.
- מכיל כתובת IP, סטטית או אלסטית (משתנה לפי AWS)
- מגן על נותני השירות ממחיקה.


### ALB - Application load balancer

- LB עבור בקשות HTTP מבוסס נתיב פנייה.
- עובד בשכבה 7, עובד עם פרוטוקולי HTTP, HTTPS, gRPC.
- מסנן פניות לפי:
  - שם DNS: שם השרת.
  - נתיב: הכתובת שלאחר שם השרת.
  - Header: מידע שמוכל בפקטה.
  - שאילתה שמופיעה בנתיב הבקשה.
  - IP מקור.
  - פעולה: מהי הפעולה שהביאה את הבקשה.
- תומך הזדהות OIDC, WAF, שהפנייה ל-Lambda, ניתוב HTTP ל-HTTPS ועוד.
- ניתוק תקשורות קיימות כברירת מחדל אחרי 60 שניות.
- שולח לוגים ל-S3.
- מגן על נותני השירות ממחיקה.

### CLB - Classic Load Balancer

- שירות deprecated שכבר לא נתמך על ידי שירותים רבים







CRM - פלטפורמה משהו, לברר מה זה