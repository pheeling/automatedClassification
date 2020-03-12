class LabelFactory {
    
    [Object] $classificationlabels

    static [LabelFactory] $instance

    static [LabelFactory] getInstance(){
        if ([LabelFactory]::instance -eq $null)
        {
            [LabelFactory]::instance = [LabelFactory]::new()
        }

        return [LabelFactory]::instance

    }

    setLabels(){
        $this.classificationlabels = Get-AadrmTemplate
    }         
}