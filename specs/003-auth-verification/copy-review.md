# Copy review (T083)

Every Arabic and English string added by feature 003 (keys not present on `develop`: 217), for Osman's review before merge. Checked against `docs/design-system/README.md` § المحتوى والصوت: light Egyptian dialect, no imperative verbs, verbal-noun buttons, gender-neutral wording, Western digits, English in sentence case. ICU plurals and `{placeholders}` are shown as stored. Generated from `lib/l10n/app_ar.arb` and `app_en.arb`; "Shown in" lists the source files that read the key.

## Sign in, sign up, email codes, password reset, account gate, general (83)

| Key | Arabic | English | Shown in |
| --- | --- | --- | --- |
| `gateTitle` | الخطوة دي محتاجة حساب | This step needs an account | account_gate |
| `gateBody` | تسجيل الدخول أو إنشاء حساب {reason} | Sign in or create an account {reason} | account_gate |
| `gateSignIn` | تسجيل الدخول | Sign in | account_gate, sign_in_prompt |
| `gateSignUp` | إنشاء حساب | Create an account | account_gate, sign_in_prompt |
| `gateDismiss` | مش دلوقتي | Not now | account_gate |
| `gateReasonBook` | عشان تحجز | to book | gate_demo |
| `gateReasonBookings` | عشان تشوف حجوزاتك | to see your bookings | sign_in_prompt |
| `gateReasonVerification` | عشان تطلب التوثيق | to request verification | ARB only (not referenced yet) |
| `gateReasonProfile` | عشان تشوف بيانات حسابك | to see your account details | profile_placeholder |
| `gateDemoBookSlot` | حجز الميعاد ده | Book this slot | gate_demo |
| `gateDemoTitle` | تجربة طلب الحساب | Account gate try-out | gate_demo |
| `gateDemoIntro` | بعد اختيار ميعاد والضغط على الحجز، الزائر بتظهر له نافذة الحساب، وبعد الدخول بيرجع هنا والميعاد لسه مختار. | Pick a slot, then tap book. A guest sees the account prompt, and after signing in comes back here with the slot still selected. | gate_demo |
| `gateDemoReady` | الحساب جاهز. الحجز ماتمش لوحده، ومحتاج ضغطة جديدة. | Account ready. Nothing was booked; tap again to continue. | gate_demo |
| `gateDemoDismissed` | اتقفلت من غير تسجيل دخول، ولسه الميعاد مختار. | Closed without signing in, and the slot is still selected. | gate_demo |
| `codeEntryLabel` | كود التأكيد | Confirmation code | code_entry |
| `codeEntrySentTo` | بعتنا كود على | The code was sent to | code_entry |
| `codeEntryResend` | إرسال الكود تاني | Resend the code | code_entry |
| `codeEntryResendIn` | إرسال الكود تاني بعد {seconds} ثانية | Resend the code in {seconds} s | code_entry |
| `signInTitle` | تسجيل الدخول | Sign in | sign_in_screen |
| `signInIdentifierLabel` | الإيميل أو رقم الموبايل | Email or mobile number | forgot_password_screen, sign_in_screen |
| `signInPasswordLabel` | الباسورد | Password | sign_in_screen |
| `signInButton` | تسجيل الدخول | Sign in | sign_in_screen, sign_up_screen |
| `signInBadCredentials` | بيانات الدخول مش صحيحة | The sign-in details are not correct | sign_in_screen |
| `signInLocked` | المحاولات كترت. الدخول متوقف مؤقتًا، وتقدر تحاول تاني بعد {minutes} دقيقة. | Too many attempts. Sign in is paused, and you can try again in {minutes} minutes. | sign_in_screen |
| `signInSuspended` | الحساب ده موقوف حاليًا. ممكن التواصل مع إدارة الجامعة. | This account is suspended. You can contact the university administration. | sign_in_screen |
| `signInForgot` | نسيت الباسورد؟ | Forgot your password? | sign_in_screen, sign_up_screen |
| `signInCreateAccount` | إنشاء حساب | Create an account | sign_in_screen |
| `forgotTitle` | استرجاع الباسورد | Reset password | forgot_password_screen |
| `forgotIntro` | اكتب الإيميل أو رقم الموبايل المسجّل، وهنبعت كود على إيميل الحساب. | Enter the email or mobile number on the account, and we'll send a code to the account's email. | forgot_password_screen |
| `forgotSendButton` | إرسال الكود | Send code | forgot_password_screen |
| `resetTitle` | باسورد جديد | Choose a new password | reset_password_screen |
| `resetSentNeutral` | لو الحساب موجود هيوصله كود على الإيميل المسجّل. | If the account exists, a code is on its way to the registered email. | reset_password_screen |
| `resetNewPasswordLabel` | الباسورد الجديد | New password | reset_password_screen |
| `resetPasswordHint` | 8 حروف على الأقل، فيها حرف ورقم | At least 8 characters, with a letter and a digit | reset_password_screen |
| `resetSaveButton` | حفظ الباسورد | Save password | reset_password_screen |
| `resetCodeWrong` | الكود غلط. المحاولات المتبقية: {tries}. | That code is wrong. Tries left: {tries}. | reset_password_screen |
| `resetCodeExpired` | الكود انتهت صلاحيته. ممكن تطلب كود جديد. | This code has expired. You can ask for a new one. | reset_password_screen |
| `resetCodeDead` | محاولات الكود خلصت. ممكن تطلب كود جديد. | No tries left on this code. You can ask for a new one. | reset_password_screen |
| `resetResendTooSoon` | ممكن تطلب كود جديد بعد {seconds} ثانية. | You can ask for a new code in {seconds} seconds. | reset_password_screen |
| `resetPasswordEmpty` | الباسورد الجديد مطلوب. | A new password is required. | reset_password_screen |
| `resetPasswordTooShort` | الباسورد لازم يكون 8 حروف على الأقل. | The password needs at least 8 characters. | reset_password_screen |
| `resetPasswordNeedsLetter` | الباسورد لازم فيه حرف واحد على الأقل. | The password needs at least one letter. | reset_password_screen |
| `resetPasswordNeedsDigit` | الباسورد لازم فيه رقم واحد على الأقل. | The password needs at least one digit. | reset_password_screen |
| `signUpTitle` | إنشاء حساب | Create an account | sign_up_screen |
| `signUpButton` | إنشاء الحساب | Create account | sign_up_screen |
| `signUpNameLabel` | الاسم بالكامل | Full name | sign_up_screen |
| `signUpNameHelper` | الاسم الأول واسم العيلة على الأقل | First and family name at least | sign_up_screen |
| `signUpPhoneLabel` | رقم الموبايل | Mobile number | sign_up_screen |
| `signUpPhoneHelper` | رقم مصري، مثال 01012345678 | An Egyptian number, for example 01012345678 | sign_up_screen |
| `signUpEmailLabel` | الإيميل | Email | sign_up_screen |
| `signUpEmailHelper` | هنبعت عليه كود تأكيد الحساب | We'll send the account confirmation code here | sign_up_screen |
| `signUpPasswordLabel` | الباسورد | Password | sign_up_screen |
| `signUpPasswordHelper` | 8 حروف على الأقل، فيها حرف ورقم | At least 8 characters, with a letter and a digit | sign_up_screen |
| `signUpAlreadyHave` | عندك حساب؟ | Already have an account? | sign_up_screen |
| `validationNameEmpty` | الاسم مطلوب. | The name is required. | validation_messages |
| `validationNameTooShort` | الاسم قصير أوي. | The name is too short. | validation_messages |
| `validationNameTooLong` | الاسم طويل، الحد الأقصى 60 حرف. | The name is too long, 60 characters at most. | validation_messages |
| `validationNameNeedsTwoWords` | الاسم لازم يكون كلمتين على الأقل، الاسم الأول واسم العيلة. | The name needs at least two words, first and family name. | validation_messages |
| `validationNameInvalidCharacters` | الاسم يقبل حروف ومسافات بس. | The name takes letters and spaces only. | validation_messages |
| `validationPhoneEmpty` | رقم الموبايل مطلوب. | The mobile number is required. | validation_messages |
| `validationPhoneInvalid` | رقم الموبايل لازم يكون 11 رقم ويبدأ بـ 010 أو 011 أو 012 أو 015. | The mobile number must be 11 digits starting with 010, 011, 012 or 015. | validation_messages |
| `validationEmailEmpty` | الإيميل مطلوب. | The email is required. | validation_messages |
| `validationEmailInvalid` | الإيميل مش مكتوب صح، مثال name@example.com. | The email is not written correctly, for example name@example.com. | validation_messages |
| `validationPasswordEmpty` | الباسورد مطلوب. | The password is required. | validation_messages |
| `validationPasswordTooShort` | الباسورد لازم يكون 8 حروف على الأقل. | The password needs at least 8 characters. | validation_messages |
| `validationPasswordNeedsLetter` | الباسورد لازم فيه حرف واحد على الأقل. | The password needs at least one letter. | validation_messages |
| `validationPasswordNeedsDigit` | الباسورد لازم فيه رقم واحد على الأقل. | The password needs at least one digit. | validation_messages |
| `signUpEmailTaken` | الإيميل ده مسجل قبل كده. | This email is already registered. | sign_up_screen |
| `signUpPhoneTaken` | رقم الموبايل ده مسجل قبل كده. | This mobile number is already registered. | sign_up_screen |
| `signUpTakenActions` | ممكن تسجيل الدخول أو استرجاع الباسورد. | You can sign in or reset the password. | sign_up_screen |
| `confirmEmailTitle` | تأكيد الإيميل | Confirm your email | confirm_email_screen |
| `confirmEmailButton` | تأكيد | Confirm | confirm_email_screen |
| `confirmCodeEmpty` | الكود مكوّن من 6 أرقام. | The code has 6 digits. | confirm_email_screen |
| `confirmCodeWrong` | الكود مش صحيح. {count, plural, =1{فاضلك محاولة واحدة} =2{فاضلك محاولتين} other{فاضلك {count} محاولات}}. | That code is not correct. {count, plural, =1{1 try left} other{{count} tries left}}. | confirm_email_screen |
| `confirmCodeExpired` | الكود انتهت صلاحيته. ممكن إرسال كود جديد. | This code has expired. You can send a new one. | confirm_email_screen |
| `confirmCodeDead` | المحاولات خلصت على الكود ده. ممكن إرسال كود جديد. | No tries left on this code. You can send a new one. | confirm_email_screen |
| `confirmNoPending` | مفيش تأكيد معلّق للإيميل ده. ممكن إنشاء حساب من جديد. | There is no pending confirmation for this email. You can create the account again. | confirm_email_screen |
| `confirmResendTooSoon` | ممكن إرسال كود جديد بعد {seconds} ثانية. | You can send a new code in {seconds} seconds. | confirm_email_screen |
| `confirmResent` | بعتنا كود جديد. | We sent a new code. | confirm_email_screen |
| `emailConfirmSubject` | كود تأكيد حسابك في سبرنت | Your Sprint account confirmation code | email_templates |
| `emailConfirmBody` | كود التأكيد: {code} الكود صالح لمدة {minutes} دقيقة. لو مش إنت اللي عملت الحساب، ممكن تتجاهل الرسالة دي. | Confirmation code: {code} The code is valid for {minutes} minutes. If you did not create this account, you can ignore this message. | email_templates |
| `emailResetSubject` | كود استرجاع الباسورد في سبرنت | Your Sprint password reset code | email_templates |
| `emailResetBody` | كود الاسترجاع: {code} الكود صالح لمدة {minutes} دقيقة. لو مش إنت اللي طلبت الاسترجاع، ممكن تتجاهل الرسالة دي. | Reset code: {code} The code is valid for {minutes} minutes. If you did not ask for a reset, you can ignore this message. | email_templates |

## Reviewer: queue, request detail, sheet upload (51)

| Key | Arabic | English | Shown in |
| --- | --- | --- | --- |
| `noAccessTitle` | الصفحة دي مش متاحة لحسابك | This page isn't available for your account | no_access_screen, verification_request_detail |
| `noAccessBody` | الصفحة دي مخصوصة لصلاحيات تانية. لو محتاج الوصول ليها ممكن تتواصل مع مسؤول الجامعة. | This page is for other permissions. If you need access, you can contact the university administrator. | no_access_screen, verification_request_detail |
| `signInUnexpected` | حصلت مشكلة غير متوقعة. ممكن المحاولة تاني بعد شوية. | Something unexpected went wrong. You can try again in a moment. | confirm_email_screen, forgot_password_screen, id_card_photo_picker, reset_password_screen, sheet_upload_screen, sign_in_screen, sign_up_screen, verification_queue_screen, verification_request_detail, verification_request_screen |
| `verifReasonLabel` | السبب: {reason} | Reason: {reason} | verification_request_detail, verification_slot |
| `verifRevQueueTitle` | طلبات التوثيق | Verification requests | verification_queue_screen |
| `verifRevQueueEmpty` | مفيش طلبات مستنية المراجعة. | No requests waiting for review. | verification_queue_screen |
| `verifRevPricing` | بعد القبول هيتحاسب بالسعر الداخلي | Priced as internal once approved | verification_queue_screen |
| `verifRevRowSpoken` | طلب {name}، {type}، {unit}، {wait} | Request from {name}, {type}, {unit}, {wait} | verification_queue_screen |
| `verifRevDetailTitle` | تفاصيل الطلب | Request details | verification_request_detail |
| `verifRevPickPrompt` | اختيار طلب من القائمة بيعرض تفاصيله هنا. | Choosing a request from the list shows its details here. | verification_queue_screen |
| `verifRevType` | النوع | Type | verification_request_detail |
| `verifRevCode` | الكود | Code | verification_request_detail |
| `verifRevUnit` | الكلية أو الإدارة | Faculty or department | verification_request_detail |
| `verifRevSubmitted` | وقت الإرسال | Sent | verification_request_detail |
| `verifRevNationalId` | الرقم القومي | National ID | verification_request_detail |
| `verifRevPhoto` | صورة البطاقة | ID card photo | verification_request_detail |
| `verifRevPhotoSpoken` | صورة بطاقة {name} | ID card photo of {name} | verification_request_detail |
| `verifRevPhotoMissing` | الصورة مش موجودة. | The photo is not available. | verification_request_detail |
| `verifRevApprove` | قبول الطلب | Approve request | verification_request_detail |
| `verifRevReject` | رفض الطلب | Reject request | verification_request_detail |
| `verifRevRejectTitle` | رفض الطلب | Reject request | verification_request_detail |
| `verifRevReasonLabel` | سبب الرفض | Reason for rejection | verification_request_detail |
| `verifRevReasonHelper` | 10 حروف على الأقل، والسبب هيظهر لصاحب الطلب. | At least 10 characters. The person will see the reason. | verification_request_detail |
| `verifRevReasonConfirm` | تأكيد الرفض | Confirm rejection | verification_request_detail |
| `verifRevReasonCancel` | رجوع | Back | verification_request_detail |
| `verifRevAlreadyDecided` | الطلب ده اتقرر فيه قبل كده. | This request was already decided. | verification_request_detail |
| `verifRevOwnRequest` | طلبك أنت مينفعش تراجعه بنفسك. | You cannot review your own request. | verification_request_detail |
| `verifRevDecidedApproved` | تم قبول الطلب، وصاحبه بقى بالسعر الداخلي. | The request was approved and the person now pays the internal price. | verification_request_detail |
| `verifRevDecidedRejected` | تم رفض الطلب، والسبب ظاهر لصاحبه. | The request was rejected and the person can see the reason. | verification_request_detail |
| `verifRevUpload` | رفع الشيت | Upload sheet | verification_queue_screen |
| `sheetTitle` | رفع شيت التوثيق | Upload verification sheet | sheet_upload_screen |
| `sheetHelp` | ملف CSV بترميز UTF-8 فيه 3 أعمدة بالترتيب: الرقم القومي، الكود، النوع (طالب أو موظف أو عضو هيئة تدريس). الصف الأول ممكن يبقى عناوين. | A UTF-8 CSV file with 3 columns in this order: national ID, code, type (student, staff or faculty). The first row may be headings. | sheet_upload_screen |
| `sheetPick` | اختيار ملف CSV | Choose a CSV file | sheet_upload_screen |
| `sheetSummaryTitle` | ملخص الرفع | Upload summary | sheet_upload_summary |
| `sheetSummaryRead` | صفوف اتقرت | Rows read | sheet_upload_summary |
| `sheetSummaryAdded` | صفوف اتضافت | Rows added | sheet_upload_summary |
| `sheetSummaryDuplicates` | صفوف مكررة اتجاهلت | Duplicate rows skipped | sheet_upload_summary |
| `sheetSummaryInvalid` | صفوف غلط اتجاهلت | Invalid rows skipped | sheet_upload_summary |
| `sheetSummaryApproved` | طلبات اتقبلت تلقائي | Requests approved automatically | sheet_upload_summary |
| `sheetProblemsTitle` | الصفوف اللي اتجاهلت | Skipped rows | sheet_upload_summary |
| `sheetProblemRow` | صف {row}: {reason} | Row {row}: {reason} | sheet_upload_summary |
| `sheetReasonColumns` | عدد الأعمدة غلط | Wrong number of columns | sheet_upload_summary |
| `sheetReasonCode` | الكود مش صالح | The code is not valid | sheet_upload_summary |
| `sheetReasonType` | النوع مش معروف | The type is not known | sheet_upload_summary |
| `sheetReasonOther` | الصف مش صالح | The row is not valid | sheet_upload_summary |
| `sheetErrBadColumns` | الأعمدة مش زي المتوقع، ومفيش حاجة اتضافت. | The columns are not the expected ones, and nothing was added. | sheet_upload_screen |
| `sheetErrNoRows` | مفيش صفوف صالحة في الملف، ومفيش حاجة اتضافت. | The file has no valid rows, and nothing was added. | sheet_upload_screen |
| `sheetErrRead` | الملف ماتقراش. ممكن تجرب ملف CSV تاني. | The file could not be read. You can try another CSV file. | sheet_upload_screen |
| `sheetBatchesTitle` | الرفعات اللي فاتت | Earlier uploads | sheet_upload_screen |
| `sheetBatchesEmpty` | لسه مفيش رفعات. | No uploads yet. | sheet_upload_screen |
| `sheetBatchLine` | اتضاف {added}، اتقبل {approved}، اتجاهل {skipped} | Added {added}, approved {approved}, skipped {skipped} | sheet_upload_screen |

## Verification request, account card, tiers (68)

| Key | Arabic | English | Shown in |
| --- | --- | --- | --- |
| `signOutTitle` | تأكيد تسجيل الخروج | Confirm sign out | account_card |
| `signOutBody` | هتفضل تقدر تتصفح التطبيق كزائر، وتسجّل دخول تاني في أي وقت. | You can keep browsing as a guest and sign in again at any time. | account_card |
| `signOutConfirm` | تسجيل الخروج | Sign out | account_card |
| `signOutKeep` | البقاء في الحساب | Stay signed in | account_card |
| `accountCardSpoken` | حسابك: {name}، {tier} | Your account: {name}, {tier} | account_card |
| `verifTitle` | طلب التوثيق | Verification request | verification_request_screen |
| `verifRenewTitle` | تجديد التوثيق | Renew verification | verification_request_screen |
| `verifIntro` | بعد التوثيق بتحجز بالسعر الداخلي. بنراجع البيانات وصورة البطاقة. | Once verified you book at the internal price. We check your details and ID card photo. | verification_request_screen |
| `verifTypeTitle` | نوع الحساب | Account type | verification_request_screen |
| `verifTypeStudent` | طالب | Student | verification_texts |
| `verifTypeStaff` | موظف | Staff | verification_texts |
| `verifTypeFaculty` | عضو هيئة تدريس | Faculty member | verification_texts |
| `verifNationalIdLabel` | الرقم القومي | National ID | verification_request_screen |
| `verifNationalIdHelper` | 14 رقم زي ما هو مكتوب في البطاقة. | 14 digits, as written on the card. | verification_request_screen |
| `verifCodeLabel` | الكود الجامعي أو الوظيفي | University or staff code | verification_request_screen |
| `verifCodeHelper` | أرقام أو حروف إنجليزي، لحد 20 خانة. | Digits or English letters, up to 20 characters. | verification_request_screen |
| `verifUnitTitle` | الكلية أو الإدارة | Faculty or department | verification_request_screen |
| `verifPhotoLabel` | صورة البطاقة | ID card photo | id_card_photo_picker |
| `verifPhotoHelper` | صورة واضحة للبطاقة كلها. بنصغّرها تلقائي قبل الإرسال. | A clear photo of the whole card. It is resized automatically before sending. | id_card_photo_picker |
| `verifPhotoChoose` | اختيار الصورة | Choose photo | id_card_photo_picker |
| `verifPhotoReplace` | تغيير الصورة | Change photo | id_card_photo_picker |
| `verifPhotoSourceTitle` | صورة البطاقة | ID card photo | id_card_photo_picker |
| `verifPhotoCamera` | تصوير بالكاميرا | Take a photo | id_card_photo_picker |
| `verifPhotoGallery` | اختيار من الصور أو الملفات | Choose from photos or files | id_card_photo_picker |
| `verifPhotoCancel` | إلغاء | Cancel | id_card_photo_picker |
| `verifPhotoProcessing` | جاري تجهيز الصورة | Preparing the photo | id_card_photo_picker |
| `verifPhotoPreviewSpoken` | معاينة صورة البطاقة | ID card photo preview | id_card_photo_picker |
| `verifPhotoNotImage` | الملف ده مش صورة. اختار صورة تانية. | That file is not an image. Choose another one. | id_card_photo_picker |
| `verifErrNationalIdEmpty` | الرقم القومي مطلوب. | National ID is required. | verification_texts |
| `verifErrNationalIdLength` | الرقم القومي لازم يكون 14 رقم. | National ID must be 14 digits. | verification_texts |
| `verifErrNationalIdCentury` | أول رقم في الرقم القومي لازم يكون 2 أو 3. | The first digit of the national ID must be 2 or 3. | verification_texts |
| `verifErrNationalIdBirthDate` | تاريخ الميلاد جوه الرقم القومي مش صحيح. | The birth date inside the national ID is not valid. | verification_texts |
| `verifErrNationalIdFuture` | تاريخ الميلاد جوه الرقم القومي لسه ماجاش. | The birth date inside the national ID is in the future. | verification_texts |
| `verifErrNationalIdGovernorate` | كود المحافظة جوه الرقم القومي مش صحيح. | The governorate code inside the national ID is not valid. | verification_texts |
| `verifErrCodeEmpty` | الكود مطلوب. | The code is required. | verification_request_screen |
| `verifErrCodeInvalid` | الكود لازم يكون من 1 لـ 20 رقم أو حرف إنجليزي. | The code must be 1 to 20 digits or English letters. | verification_request_screen, verification_texts |
| `verifErrUnitEmpty` | اختار الكلية أو الإدارة. | Choose the faculty or department. | verification_request_screen, verification_texts |
| `verifErrPhotoEmpty` | صورة البطاقة مطلوبة. | The ID card photo is required. | verification_request_screen, verification_texts |
| `verifSubmit` | إرسال الطلب | Send request | verification_request_screen |
| `verifSubmitting` | جاري إرسال الطلب | Sending the request | ARB only (not referenced yet) |
| `verifResultApproved` | تم التوثيق. سعرك داخلي لحد {date}. | Verified. Your price is internal until {date}. | verification_request_screen |
| `verifResultPending` | الطلب اتبعت وبيتراجع. لحد ما يخلص هتفضل بالسعر الكامل. | Request sent and under review. Until it is done you stay on the full price. | verification_request_screen |
| `verifResultRejected` | الطلب اترفض. السبب: {reason} | The request was refused. Reason: {reason} | verification_request_screen |
| `verifResultDone` | تمام | Done | verification_request_screen |
| `verifReasonDuplicate` | الرقم القومي ده عليه طلب توثيق من حساب تاني. | This national ID already has a verification request from another account. | verification_texts |
| `verifStorageFull` | الصورة متحفظتش، ممكن تبعتها تاني | The photo was not saved, you can send it again | verification_request_screen |
| `verifAlreadyPending` | عندك طلب قيد المراجعة بالفعل. | You already have a request under review. | verification_request_screen |
| `verifCardTitle` | التوثيق | Verification | verification_slot |
| `verifCardSpoken` | التوثيق: {status} | Verification: {status} | verification_slot |
| `verifStatusNone` | غير موثّق | Not verified | verification_texts |
| `verifStatusExpired` | التوثيق انتهى | Verification expired | verification_slot, verification_texts |
| `verifNoneBody` | حسابك بالسعر الكامل. بعد التوثيق بتحجز بالسعر الداخلي. | Your account is on the full price. Once verified you book at the internal price. | verification_slot |
| `verifPendingBody` | طلبك قيد المراجعة. لحد ما يخلص هتفضل بالسعر الكامل. | Your request is under review. Until it is done you stay on the full price. | verification_slot |
| `verifApprovedUntil` | متوثق لحد {date} | Verified until {date} | verification_slot |
| `verifRejectedBody` | الطلب اترفض. | The request was refused. | verification_slot |
| `verifExpiredBody` | التوثيق انتهى يوم {date}. السعر دلوقتي كامل لحد التجديد. | Verification expired on {date}. The price is full until you renew. | verification_slot |
| `verifActionRequest` | طلب التوثيق | Request verification | verification_slot |
| `verifActionRenew` | تجديد التوثيق | Renew verification | verification_request_screen, verification_slot |
| `verifActionAgain` | إرسال طلب جديد | Send a new request | verification_slot |
| `verifActionWait` | في انتظار المراجعة | Waiting for review | verification_slot |
| `verifNationalIdMasked` | الرقم القومي: {id} | National ID: {id} | verification_slot |
| `verifRevSection` | التوثيق | Verification | verification_destination |
| `verifRevWaitMinutes` | {count, plural, =0{مستني من أقل من دقيقة} =1{مستني من دقيقة} =2{مستني من دقيقتين} other{مستني من {count} دقايق}} | {count, plural, =0{Waiting less than a minute} =1{Waiting 1 minute} other{Waiting {count} minutes}} | verification_texts |
| `verifRevWaitHours` | {count, plural, =1{مستني من ساعة} =2{مستني من ساعتين} other{مستني من {count} ساعات}} | {count, plural, =1{Waiting 1 hour} other{Waiting {count} hours}} | verification_texts |
| `verifRevWaitDays` | {count, plural, =1{مستني من يوم} =2{مستني من يومين} other{مستني من {count} أيام}} | {count, plural, =1{Waiting 1 day} other{Waiting {count} days}} | verification_texts |
| `verifRevName` | الاسم | Name | ARB only (not referenced yet) |
| `verifNoticeApproved` | تم قبول طلب التوثيق. متوثق لحد {date}. | Your verification request was approved. Verified until {date}. | verification_notice |
| `verifNoticeRejected` | طلب التوثيق اترفض. السبب: {reason} | Your verification request was rejected. Reason: {reason} | verification_notice |

## Demo tools and demo mailbox (15)

| Key | Arabic | English | Shown in |
| --- | --- | --- | --- |
| `demoNoticeTitle` | للعرض بس | Demo only | demo_code_notice |
| `demoNoticeCode` | كود التجربة: {code} | Demo code: {code} | demo_code_notice |
| `demoNoticeDismiss` | إخفاء | Hide | demo_code_notice |
| `mailboxTitle` | صندوق البريد التجريبي | Demo mailbox | demo_screen, mailbox_screen |
| `demoResetButton` | إرجاع الداتا التجريبية | Reset demo data | demo_screen |
| `demoResetTitle` | إرجاع الداتا التجريبية؟ | Reset the demo data? | demo_screen |
| `demoResetBody` | كل الحجوزات والحسابات والطلبات اللي اتعملت هتتمسح، والداتا هترجع زي أول مرة. المظهر واللغة هيفضلوا زي ما هما. | Every booking, account and request made so far is removed and the data goes back to how it started. Theme and language stay as they are. | demo_screen |
| `demoResetConfirm` | إرجاع الداتا | Reset data | demo_screen |
| `demoResetKeep` | إلغاء | Cancel | demo_screen |
| `mailboxNote` | الرسائل اللي التطبيق كان هيبعتها بالإيميل بتظهر هنا. للمراجعين فقط. | Emails the app would have sent appear here. For reviewers only. | mailbox_screen |
| `mailboxEmptyTitle` | مفيش رسائل لسه | No messages yet | mailbox_screen |
| `mailboxEmptyBody` | أي كود تأكيد أو استرجاع هيتبعت هيظهر هنا. | Any confirmation or reset code that is sent will appear here. | mailbox_screen |
| `mailboxTo` | إلى | To | mailbox_screen |
| `mailboxCopyCode` | نسخ الكود | Copy code | mailbox_screen |
| `mailboxCopied` | الكود اتنسخ. | Code copied. | mailbox_screen |
Note: `gateReasonVerification`, `verifSubmitting` and `verifRevName` are not read by any screen yet; remove them or wire them before merge.
