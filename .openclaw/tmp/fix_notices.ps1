$content = Get-Content 'E:\kwangmin\ai\healthon-platform\healthon-platform-main\apps\mobile\lib\features\admin\screens\admin_notices_screen.dart' -Raw -Encoding UTF8
$content = $content.Replace('_addTag()', 'addTag()').Replace('_addImageUrl()', 'addImageUrl()').Replace('_addAttachment()', 'addAttachment()')
[IO.File]::WriteAllText('E:\kwangmin\ai\healthon-platform\healthon-platform-main\apps\mobile\lib\features\admin\screens\admin_notices_screen.dart', $content, [Text.Encoding]::UTF8)
