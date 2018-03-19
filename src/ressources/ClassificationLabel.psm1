class ClassificationLabel {
    [String] $name
    [String] $id
    [String] $owner
    [ClassificationLabel[]] $classificationSubLabelArray

    Policy([String] $name, [String] $id){
        $this.name = $name
        $this.id = $id
    }

    [ClassificationLabel[]] getLabel(){
        return $null
    }
}
