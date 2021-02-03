function Search-CIM {
$search_key=$args[0]

$cimclass = (Get-CimClass).CimClassName
$cimclass_search = ($cimclass -match $search_key)


foreach ($class in $cimclass_search)
{
Get-CimInstance -ClassName $class
}
}
