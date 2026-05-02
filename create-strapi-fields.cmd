@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM Creates/updates Strapi v4 content-type schema.json files with all fields and relations.
REM Run from the root of your Strapi project.

if not exist package.json (
  echo [ERROR] package.json not found. Run this from the Strapi project root.
  exit /b 1
)

if "%STRAPI_SRC%"=="" set STRAPI_SRC=src
set SCRIPT_DIR=%~dp0
set TEMP_JS=%TEMP%\strapi-fields-%RANDOM%%RANDOM%.js

where node >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Node.js is required but was not found in PATH.
  exit /b 1
)

> "%TEMP_JS%" echo const fs = require('fs');
>> "%TEMP_JS%" echo const path = require('path');
>> "%TEMP_JS%" echo const root = process.cwd();
>> "%TEMP_JS%" echo const srcDir = process.env.STRAPI_SRC ^|^| 'src';
>> "%TEMP_JS%" echo const defs = [
>> "%TEMP_JS%" echo { singularName:'city', pluralName:'cities', displayName:'City', kind:'collectionType', attributes:{ name:{type:'string',required:true}, slug:{type:'uid',targetField:'name',required:true,unique:true}, image_url:{type:'string',required:true}, description:{type:'richtext'}, is_published:{type:'boolean',required:true,default:true}, artists:{type:'relation',relation:'oneToMany',target:'api::artist.artist',mappedBy:'city'}, artist_events:{type:'relation',relation:'oneToMany',target:'api::artist-event.artist-event',mappedBy:'city'} } },
>> "%TEMP_JS%" echo { singularName:'artist', pluralName:'artists', displayName:'Artist', kind:'collectionType', attributes:{ name:{type:'string',required:true}, slug:{type:'uid',targetField:'name',required:true,unique:true}, bio:{type:'richtext'}, profile_image:{type:'string'}, cover_image:{type:'string'}, medium:{type:'string'}, is_published:{type:'boolean',required:true,default:true}, rating:{type:'decimal',default:0}, total_reviews:{type:'integer',default:0}, city:{type:'relation',relation:'manyToOne',target:'api::city.city',inversedBy:'artists'}, artworks:{type:'relation',relation:'oneToMany',target:'api::artwork.artwork',mappedBy:'artist'}, artist_quiz:{type:'relation',relation:'oneToOne',target:'api::artist-quiz.artist-quiz',mappedBy:'artist'}, user_discounts:{type:'relation',relation:'oneToMany',target:'api::user-discount.user-discount',mappedBy:'artist'}, artist_events:{type:'relation',relation:'oneToMany',target:'api::artist-event.artist-event',mappedBy:'artist'}, products:{type:'relation',relation:'oneToMany',target:'api::product.product',mappedBy:'artist'} } },
>> "%TEMP_JS%" echo { singularName:'artwork', pluralName:'artworks', displayName:'Artwork', kind:'collectionType', attributes:{ title:{type:'string',required:true}, image_url:{type:'string',required:true}, year:{type:'integer'}, medium:{type:'string'}, dimensions:{type:'string'}, price:{type:'decimal'}, artist:{type:'relation',relation:'manyToOne',target:'api::artist.artist',inversedBy:'artworks'}, artwork_description:{type:'relation',relation:'oneToOne',target:'api::artwork-description.artwork-description',inversedBy:'artwork'}, artwork_reviews:{type:'relation',relation:'oneToMany',target:'api::artwork-review.artwork-review',mappedBy:'artwork'}, wall_uploads:{type:'relation',relation:'oneToMany',target:'api::wall-upload.wall-upload',mappedBy:'artwork'}, products:{type:'relation',relation:'oneToMany',target:'api::product.product',mappedBy:'artwork'} } },
>> "%TEMP_JS%" echo { singularName:'wall-upload', pluralName:'wall-uploads', displayName:'Wall Upload', kind:'collectionType', attributes:{ image_url:{type:'string',required:true}, session_id:{type:'string',required:true}, artwork:{type:'relation',relation:'manyToOne',target:'api::artwork.artwork',inversedBy:'wall_uploads'} } },
>> "%TEMP_JS%" echo { singularName:'artwork-description', pluralName:'artwork-descriptions', displayName:'Artwork Description', kind:'collectionType', attributes:{ description:{type:'richtext',required:true}, artwork:{type:'relation',relation:'oneToOne',target:'api::artwork.artwork',mappedBy:'artwork_description'} } },
>> "%TEMP_JS%" echo { singularName:'artwork-review', pluralName:'artwork-reviews', displayName:'Artwork Review', kind:'collectionType', attributes:{ rating:{type:'integer',required:true,min:1,max:5}, comment:{type:'text'}, session_id:{type:'string',required:true}, artwork:{type:'relation',relation:'manyToOne',target:'api::artwork.artwork',inversedBy:'artwork_reviews'} } },
>> "%TEMP_JS%" echo { singularName:'artist-quiz', pluralName:'artist-quizzes', displayName:'Artist Quiz', kind:'collectionType', attributes:{ title:{type:'string',required:true}, description:{type:'richtext'}, artist:{type:'relation',relation:'oneToOne',target:'api::artist.artist',inversedBy:'artist_quiz'}, quiz_questions:{type:'relation',relation:'oneToMany',target:'api::quiz-question.quiz-question',mappedBy:'artist_quiz'}, quiz_answers:{type:'relation',relation:'oneToMany',target:'api::quiz-answer.quiz-answer',mappedBy:'artist_quiz'} } },
>> "%TEMP_JS%" echo { singularName:'quiz-question', pluralName:'quiz-questions', displayName:'Quiz Question', kind:'collectionType', attributes:{ question:{type:'string',required:true}, correct_answer:{type:'string',required:true}, option_a:{type:'string',required:true}, option_b:{type:'string',required:true}, option_c:{type:'string',required:true}, option_d:{type:'string',required:true}, artist_quiz:{type:'relation',relation:'manyToOne',target:'api::artist-quiz.artist-quiz',inversedBy:'quiz_questions'} } },
>> "%TEMP_JS%" echo { singularName:'quiz-answer', pluralName:'quiz-answers', displayName:'Quiz Answer', kind:'collectionType', attributes:{ score:{type:'integer',required:true}, total_questions:{type:'integer',required:true}, session_id:{type:'string',required:true}, artist_quiz:{type:'relation',relation:'manyToOne',target:'api::artist-quiz.artist-quiz',inversedBy:'quiz_answers'} } },
>> "%TEMP_JS%" echo { singularName:'artist-event', pluralName:'artist-events', displayName:'Artist Event', kind:'collectionType', attributes:{ title:{type:'string',required:true}, description:{type:'richtext'}, event_date:{type:'datetime',required:true}, location:{type:'string'}, image_url:{type:'string'}, city:{type:'relation',relation:'manyToOne',target:'api::city.city',inversedBy:'artist_events'}, artist:{type:'relation',relation:'manyToOne',target:'api::artist.artist',inversedBy:'artist_events'} } },
>> "%TEMP_JS%" echo { singularName:'user-discount', pluralName:'user-discounts', displayName:'User Discount', kind:'collectionType', attributes:{ discount_code:{type:'string',required:true,unique:true}, discount_percentage:{type:'integer',required:true,min:0,max:100}, used:{type:'boolean',required:true,default:false}, session_id:{type:'string',required:true}, artist:{type:'relation',relation:'manyToOne',target:'api::artist.artist',inversedBy:'user_discounts'} } },
>> "%TEMP_JS%" echo { singularName:'product', pluralName:'products', displayName:'Product', kind:'collectionType', attributes:{ title:{type:'string',required:true}, description:{type:'text'}, image_url:{type:'string',required:true}, price:{type:'decimal',required:true}, category:{type:'string',required:true,default:'artwork'}, stock_quantity:{type:'integer',required:true,default:999}, is_available:{type:'boolean',required:true,default:true}, artist:{type:'relation',relation:'manyToOne',target:'api::artist.artist',inversedBy:'products'}, artwork:{type:'relation',relation:'manyToOne',target:'api::artwork.artwork',inversedBy:'products'}, cart_items:{type:'relation',relation:'oneToMany',target:'api::cart-item.cart-item',mappedBy:'product'}, order_items:{type:'relation',relation:'oneToMany',target:'api::order-item.order-item',mappedBy:'product'} } },
>> "%TEMP_JS%" echo { singularName:'cart-item', pluralName:'cart-items', displayName:'Cart Item', kind:'collectionType', attributes:{ session_id:{type:'string',required:true}, quantity:{type:'integer',required:true,min:1}, product:{type:'relation',relation:'manyToOne',target:'api::product.product',inversedBy:'cart_items'} } },
>> "%TEMP_JS%" echo { singularName:'order', pluralName:'orders', displayName:'Order', kind:'collectionType', attributes:{ session_id:{type:'string',required:true}, customer_name:{type:'string',required:true}, customer_email:{type:'email',required:true}, customer_phone:{type:'string'}, delivery_address:{type:'string',required:true}, delivery_city:{type:'string',required:true}, delivery_postal:{type:'string'}, total_amount:{type:'decimal',required:true}, discount_code:{type:'string'}, discount_amount:{type:'decimal',default:0}, final_amount:{type:'decimal',required:true}, status:{type:'string',required:true,default:'pending'}, payment_status:{type:'string',required:true,default:'pending'}, notes:{type:'text'}, order_items:{type:'relation',relation:'oneToMany',target:'api::order-item.order-item',mappedBy:'order'} } },
>> "%TEMP_JS%" echo { singularName:'order-item', pluralName:'order-items', displayName:'Order Item', kind:'collectionType', attributes:{ product_title:{type:'string',required:true}, product_price:{type:'decimal',required:true}, quantity:{type:'integer',required:true,min:1}, subtotal:{type:'decimal',required:true}, order:{type:'relation',relation:'manyToOne',target:'api::order.order',inversedBy:'order_items'}, product:{type:'relation',relation:'manyToOne',target:'api::product.product',inversedBy:'order_items'} } }
>> "%TEMP_JS%" echo ];
>> "%TEMP_JS%" echo const ensureDir = d =^> fs.mkdirSync(d, { recursive: true });
>> "%TEMP_JS%" echo const writeJson = ^(f, o^) =^> fs.writeFileSync(f, JSON.stringify(o, null, 2) + '\n');
>> "%TEMP_JS%" echo for ^(const ct of defs^) {
>> "%TEMP_JS%" echo   const dir = path.join(root, srcDir, 'api', ct.singularName, 'content-types', ct.singularName);
>> "%TEMP_JS%" echo   ensureDir(dir);
>> "%TEMP_JS%" echo   const schemaFile = path.join(dir, 'schema.json');
>> "%TEMP_JS%" echo   let existing = {};
>> "%TEMP_JS%" echo   if ^(fs.existsSync(schemaFile)^) {
>> "%TEMP_JS%" echo     try { existing = JSON.parse(fs.readFileSync(schemaFile, 'utf8')); } catch ^(e^) {}
>> "%TEMP_JS%" echo   }
>> "%TEMP_JS%" echo   const out = {
>> "%TEMP_JS%" echo     kind: ct.kind,
>> "%TEMP_JS%" echo     collectionName: existing.collectionName ^|^| ct.pluralName.replace(/-/g, '_'),
>> "%TEMP_JS%" echo     info: { singularName: ct.singularName, pluralName: ct.pluralName, displayName: ct.displayName },
>> "%TEMP_JS%" echo     options: existing.options ^|^| { draftAndPublish: false },
>> "%TEMP_JS%" echo     pluginOptions: existing.pluginOptions ^|^| {},
>> "%TEMP_JS%" echo     attributes: ct.attributes
>> "%TEMP_JS%" echo   };
>> "%TEMP_JS%" echo   writeJson(schemaFile, out);
>> "%TEMP_JS%" echo   console.log('[OK] Updated fields for ' + ct.displayName + ' -> ' + schemaFile);
>> "%TEMP_JS%" echo }
>> "%TEMP_JS%" echo console.log('\nDone. Restart Strapi and inspect the fields in the admin UI.');

node "%TEMP_JS%"
set ERR=%ERRORLEVEL%
del "%TEMP_JS%" >nul 2>nul

if not "%ERR%"=="0" (
  echo [ERROR] Failed to update content-type fields.
  exit /b %ERR%
)

echo.
echo Next steps:
echo 1. Restart Strapi: npm run develop
echo 2. Open Content-Type Builder or Content Manager
echo 3. Confirm fields, defaults, and relations
echo 4. If Strapi shows schema mismatch errors, remove the affected type and re-run on a clean DB

endlocal
