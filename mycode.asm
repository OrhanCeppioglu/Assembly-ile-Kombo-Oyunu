org 100h

jmp ana_baslangic

; ekrandaki yazilar
yazi_giris    db "Verilen Ok Tuslarina Basin!", 0Dh, 0Ah, "$"
yazi_sev1     db 0Dh, 0Ah, "SEVIYE 1 - Normal Hiz", 0Dh, 0Ah, "$"
yazi_sev2     db 0Dh, 0Ah, "SEVIYE 2 - Yuksek Hiz!", 0Dh, 0Ah, "$"
yazi_sev3     db 0Dh, 0Ah, "SEVIYE 3 - En Yuksek Hiz!!!", 0Dh, 0Ah, "$"
yazi_kombo    db " tusuna basin, Kombo: ", "$"
yazi_geckald  db 0Dh, 0Ah, "Sure Doldu! Kombo Sifirlandi.", 0Dh, 0Ah, "$"
yazi_yanlis   db 0Dh, 0Ah, "Yanlis Tus! Kombo Sifirlandi.", 0Dh, 0Ah, "$"
yeni_satir    db 0Dh, 0Ah, "$"
yazi_bitis    db 0Dh, 0Ah, 0Dh, 0Ah, "OYUN BITTI!!!", 0Dh, 0Ah, "$"
yazi_skor     db "Toplam Dogru Tus Sayisi: $"
yazi_rekor    db 0Dh, 0Ah, "En Yuksek Kombo: $"

; kombolar
kombo_0 db "YOK$"
kombo_1 db "D$"
kombo_2 db "C$"
kombo_3 db "B$"
kombo_4 db "A$"
kombo_5 db "S$"
kombo_6 db "SS$"
kombo_7 db "SSS!$"
kombolar dw kombo_0, kombo_1, kombo_2, kombo_3, kombo_4, kombo_5, kombo_6, kombo_7

; gerekli degiskenler
ok_sekilleri db 24, 25, 27, 26         ; ok isaretlerinin ascii kodlari
tus_kodlari  db 48h, 50h, 4Bh, 4Dh     ; tuslarin donanimsal karsiligi

beklenen_ok  dw 0 
anlik_kombo  dw 0
anlik_vurus  dw 0
en_iyi_kombo dw 0  
toplam_dogru dw 0  
oyun_asamasi dw 1  
anlik_hiz    dw 70
oyun_sayaci  dw 0
tur_sayaci   dw 0

ana_baslangic:
    mov ax, cs
    mov ds, ax
    mov es, ax

    ; giris mesajlarini yaz
    mov ah, 09h
    lea dx, yazi_giris
    int 21h
    lea dx, yazi_sev1
    int 21h

    ; oyunu baslat ve saati al
    mov ah, 00h
    int 1Ah
    mov [oyun_sayaci], dx

yeni_hedef:
    ; ne kadar sure gectigine bakiyoruz
    mov ah, 00h
    int 1Ah
    mov bx, dx
    sub bx, [oyun_sayaci]  
                          
    ; 45 saniye olduysa oyunu bitir
    cmp bx, 810
    jae skor_ekrani
    
    ; 30 saniye olduysa seviye 3'e gec
    cmp bx, 540
    jae asama3_kontrol   
    
    ; 15 saniye olduysa seviye 2'ye gec
    cmp bx, 270
    jae asama2_kontrol    

    ; seviye 1 hizi
    mov [anlik_hiz], 70
    jmp yon_belirle

asama2_kontrol:
    cmp [oyun_asamasi], 2
    je asama2_hiz_ayarla       
    mov [oyun_asamasi], 2  
    mov ah, 09h
    lea dx, yazi_sev2
    int 21h
asama2_hiz_ayarla:
    mov [anlik_hiz], 40
    jmp yon_belirle

asama3_kontrol:
    cmp [oyun_asamasi], 3
    je asama3_hiz_ayarla
    mov [oyun_asamasi], 3
    mov ah, 09h
    lea dx, yazi_sev3
    int 21h
asama3_hiz_ayarla:
    mov [anlik_hiz], 18

yon_belirle:
    ; ekrana cikaracak rastgele bir ok sec
    mov ah, 00h
    int 1Ah
    mov ax, dx
    xor dx, dx
    mov cx, 4
    div cx
    
    cmp dx, [beklenen_ok]
    je yon_belirle
    mov [beklenen_ok], dx

    ; ekrana oku ve anlik komboyu bastir
    mov ah, 09h
    lea dx, yeni_satir
    int 21h

    mov bx, [beklenen_ok]
    mov dl, ok_sekilleri[bx]
    mov ah, 02h
    int 21h

    mov ah, 09h
    lea dx, yazi_kombo
    int 21h

    mov bx, [anlik_kombo]
    shl bx, 1
    mov dx, kombolar[bx]
    mov ah, 09h
    int 21h

    ; oyuncunun suresini baslat
    mov ah, 00h
    int 1Ah
    mov [tur_sayaci], dx

klavye_bekle:
    mov ah, 00h
    int 1Ah
    mov bx, dx
    sub bx, [tur_sayaci] 

    cmp bx, [anlik_hiz]
    jae zaman_asimi

    mov ah, 01h
    int 16h
    jnz tusa_basildi
    jmp klavye_bekle

tusa_basildi:
    ; klavyeden basilan tusa bak
    mov ah, 00h
    int 16h
    mov bx, [beklenen_ok]
    mov cl, tus_kodlari[bx]
    
    cmp ah, cl
    je dogru_tus
    jmp yanlis_tus

dogru_tus:
    inc [toplam_dogru]

    ; rekor komboyu yenilediysek kaydet
    mov ax, [anlik_kombo]
    cmp ax, [en_iyi_kombo]
    jbe hiz_olcer     
    mov [en_iyi_kombo], ax  

hiz_olcer:
    ; verilen surenin yarisindan once mi basmis onu kontrol et
    mov ah, 00h
    int 1Ah
    mov bx, dx
    sub bx, [tur_sayaci]

    mov ax, [anlik_hiz]
    shr ax, 1            

    cmp bx, ax
    jbe seri_basildi

yavas_kaldin:
    mov [anlik_vurus], 0
    jmp yeni_hedef

seri_basildi:
    inc [anlik_vurus]
    cmp [anlik_vurus], 3
    jb yeni_hedef

    ; 3 defa hizli bastiysa komboyu artir
    mov [anlik_vurus], 0
    cmp [anlik_kombo], 7
    jae yeni_hedef
    inc [anlik_kombo]
    
    mov ax, [anlik_kombo]
    cmp ax, [en_iyi_kombo]
    jbe yeni_hedef
    mov [en_iyi_kombo], ax
    jmp yeni_hedef

; ceza kisimlari
zaman_asimi:
    mov ah, 09h
    lea dx, yazi_geckald
    int 21h
    jmp kombo_bozuldu

yanlis_tus:
    mov ah, 09h
    lea dx, yazi_yanlis
    int 21h
    jmp kombo_bozuldu

kombo_bozuldu:
    mov [anlik_kombo], 0
    mov [anlik_vurus], 0
    jmp yeni_hedef

; oyun bitince gosterilecekler
skor_ekrani:
    mov ah, 09h
    lea dx, yazi_bitis
    int 21h

    ; dogru bilinen sayisini yaz
    lea dx, yazi_skor
    int 21h
    mov ax, [toplam_dogru]
    call ekrana_yaz

    ; ulastigi en yuksek komboyu goster
    mov ah, 09h
    lea dx, yazi_rekor
    int 21h

    mov bx, [en_iyi_kombo]
    shl bx, 1
    mov dx, kombolar[bx]
    mov ah, 09h
    int 21h

    ; cikis
    mov ah, 4Ch
    int 21h

; sayilari ekrana basan fonksiyon
ekrana_yaz proc
    push ax
    push bx
    push cx
    push dx
    
    mov bx, 10
    mov cx, 0
    
    cmp ax, 0
    jne basamaklara_ayir
    mov ah, 02h
    mov dl, '0'
    int 21h
    jmp fonksiyondan_cik
    
basamaklara_ayir:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne basamaklara_ayir
rakamlari_bas:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop rakamlari_bas
fonksiyondan_cik:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ekrana_yaz endp

end ana_baslangic