# आसान हिंदी सेटअप

1. ZIP को कंप्यूटर में Extract करें।
2. Node.js 20+ इंस्टॉल करें। प्रोजेक्ट फोल्डर में Terminal खोलें और `npm install` चलाएँ।
3. `.env.example` की कॉपी बनाकर उसका नाम `.env` रखें। Supabase Project URL और anon/publishable key भरें।
4. Supabase Dashboard → SQL Editor में `supabase/schema.sql` का पूरा SQL चलाएँ।
5. Supabase → Authentication → Users में अपना Admin ईमेल/पासवर्ड बनाएँ। Public sign-up बंद रखें।
6. उस Admin का UUID कॉपी करके SQL Editor में चलाएँ:

```sql
insert into public.admin_users (user_id) values ('यहाँ-अपना-UUID-डालें');
```

7. Terminal में `npm run dev` से लोकल टेस्ट करें और `npm run build` से Production build जाँचें।
8. GitHub पर प्रोजेक्ट push करके Vercel में Import करें। Vercel में दोनों Environment Variables जोड़कर Deploy करें।
9. वेबसाइट चालू होने के बाद एक टेस्ट दुकान बनाएँ। उसके पब्लिक पेज, QR scan, PDF size और NFC को असली डिवाइस पर जाँचें।

**सुरक्षा:** Supabase का service-role key कभी `.env` के frontend `VITE_` variable में न डालें और ZIP/GitHub में `.env` अपलोड न करें।
