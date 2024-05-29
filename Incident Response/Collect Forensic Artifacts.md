# Collect Forensic Artifacts

- Install powershell-yaml

```
Install-Module powershell-yaml
```

- Get an object of forensic artifacts

```
$WindowsArtifacts=$(curl https://raw.githubusercontent.com/ForensicArtifacts/artifacts/main/artifacts/data/windows.yaml)
$obj = ConvertFrom-Yaml $WindowsArtifacts.Content -AllDocuments
```

- Now that it is stored within a format we can use the below will give us information at a glance

```
$count=0;
foreach ($Artifact in $obj){
$Artifacts = [pscustomobject][ordered]@{
	Name = $obj.name[$count]
	Description = $obj.doc[$count]
	References = $obj.urls[$count]
	Attributes = $obj.sources.attributes[$count]
}
$count++;
$Artifacts | FL;
}
```

- Query object for relevant registry keys

```
$obj.sources.attributes.keys|Select-String "HKEY"
$obj.sources.attributes.key_value_pairs
```

- Query object for relevant file paths

```
$obj.sources.attributes.paths
```
