@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM Run this from the root of a Strapi v4 project.
REM Example:
REM   create-strapi-content-types.cmd
REM Optional env var:
REM   set STRAPI_SRC=src

if not exist package.json (
  echo [ERROR] package.json not found. Run this from the Strapi project root.
  exit /b 1
)

if "%STRAPI_SRC%"=="" set STRAPI_SRC=src
set SCHEMA_FILE=%~dp0strapi-content-types-schema.json

if not exist "%SCHEMA_FILE%" (
  echo [ERROR] Schema file not found: %SCHEMA_FILE%
  exit /b 1
)

where node >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Node.js is required but was not found in PATH.
  exit /b 1
)

set TEMP_JS=%TEMP%\strapi-create-types-%RANDOM%%RANDOM%.js

> "%TEMP_JS%" echo const fs = require('fs');
>> "%TEMP_JS%" echo const path = require('path');
>> "%TEMP_JS%" echo const root = process.cwd();
>> "%TEMP_JS%" echo const srcDir = process.env.STRAPI_SRC ^|^| 'src';
>> "%TEMP_JS%" echo const schemaPath = path.resolve(process.argv[2]);
>> "%TEMP_JS%" echo const data = JSON.parse(fs.readFileSync(schemaPath, 'utf8'));
>> "%TEMP_JS%" echo const pascal = s =^> s.split('-').map(v =^> v.charAt(0).toUpperCase() + v.slice(1)).join('');
>> "%TEMP_JS%" echo const ensureDir = dir =^> fs.mkdirSync(dir, { recursive: true });
>> "%TEMP_JS%" echo const writeJson = ^(file, obj^) =^> fs.writeFileSync(file, JSON.stringify(obj, null, 2) + '\n');
>> "%TEMP_JS%" echo for ^(const ct of data.contentTypes^) {
>> "%TEMP_JS%" echo   const baseDir = path.join(root, srcDir, 'api', ct.singularName, 'content-types', ct.singularName);
>> "%TEMP_JS%" echo   ensureDir(baseDir);
>> "%TEMP_JS%" echo   const schema = {
>> "%TEMP_JS%" echo     kind: ct.kind ^|^| 'collectionType',
>> "%TEMP_JS%" echo     collectionName: ct.pluralName.replace(/-/g, '_'),
>> "%TEMP_JS%" echo     info: {
>> "%TEMP_JS%" echo       singularName: ct.singularName,
>> "%TEMP_JS%" echo       pluralName: ct.pluralName,
>> "%TEMP_JS%" echo       displayName: ct.displayName
>> "%TEMP_JS%" echo     },
>> "%TEMP_JS%" echo     options: { draftAndPublish: false },
>> "%TEMP_JS%" echo     pluginOptions: {},
>> "%TEMP_JS%" echo     attributes: ct.attributes
>> "%TEMP_JS%" echo   };
>> "%TEMP_JS%" echo   writeJson(path.join(baseDir, 'schema.json'), schema);
>> "%TEMP_JS%" echo   const routerDir = path.join(root, srcDir, 'api', ct.singularName, 'routes');
>> "%TEMP_JS%" echo   const controllerDir = path.join(root, srcDir, 'api', ct.singularName, 'controllers');
>> "%TEMP_JS%" echo   const serviceDir = path.join(root, srcDir, 'api', ct.singularName, 'services');
>> "%TEMP_JS%" echo   ensureDir(routerDir); ensureDir(controllerDir); ensureDir(serviceDir);
>> "%TEMP_JS%" echo   const factoryId = 'api::' + ct.singularName + '.' + ct.singularName;
>> "%TEMP_JS%" echo   fs.writeFileSync(path.join(routerDir, ct.singularName + '.js'), "'use strict';\n\nconst { createCoreRouter } = require('@strapi/strapi').factories;\n\nmodule.exports = createCoreRouter('" + factoryId + "');\n");
>> "%TEMP_JS%" echo   fs.writeFileSync(path.join(controllerDir, ct.singularName + '.js'), "'use strict';\n\nconst { createCoreController } = require('@strapi/strapi').factories;\n\nmodule.exports = createCoreController('" + factoryId + "');\n");
>> "%TEMP_JS%" echo   fs.writeFileSync(path.join(serviceDir, ct.singularName + '.js'), "'use strict';\n\nconst { createCoreService } = require('@strapi/strapi').factories;\n\nmodule.exports = createCoreService('" + factoryId + "');\n");
>> "%TEMP_JS%" echo   console.log('[OK] Created ' + ct.displayName + ' (' + ct.singularName + ')');
>> "%TEMP_JS%" echo }
>> "%TEMP_JS%" echo console.log('\nDone. Restart Strapi so it picks up the new content-types.');

node "%TEMP_JS%" "%SCHEMA_FILE%"
set ERR=%ERRORLEVEL%
del "%TEMP_JS%" >nul 2>nul

if not "%ERR%"=="0" (
  echo [ERROR] Generation failed.
  exit /b %ERR%
)

echo.
echo Next steps:
echo 1. Review generated files under %STRAPI_SRC%\api
echo 2. Run: npm run develop
echo 3. In Strapi admin, verify attributes and relation labels
echo 4. If needed, delete unwanted auto-generated tables before re-running on a used DB

endlocal
