Function Get-PriceLimit
{

    [cmdletbinding()]
    param(
        [Alias("AveragePrice")]
        [Parameter(Position=0,Mandatory=$true)]
        [decimal]
        $GjennomsnittsPris,
        [Alias("Brutto","BruttoPris")]
        [decimal]
        $Pris,
        [switch]$IgnoreNettleie,
        [decimal]
        $NettleieDag = 0.4364,
        [decimal]
        $NettleieNatt = 0.3739,
        [decimal]
        $NettleieDagRedusert = 0.3529,
        [decimal]
        $NettleieNattRedusert = 0.2904,
        [decimal]
        $Prosent = 90,
        [decimal]
        $Grense = 0.70,
        [int]
        $Month = (get-date).Month,
        [string]
        $DayOfWeek = (get-date).Dayofweek,
        [Alias("Time")]
        [int]
        $hour = (get-date).Hour
    )
    Begin
    {

    }
    Process
    {
        if ( -not $IgnoreNettleie )
        {
            if ( $DayOfWeek -eq "Saturday" -or $DayOfWeek -eq "Sunday" -or $DayOfWeek -eq "Lørdag" -or $DayOfWeek -eq "Søndag" )
            {
                $nattHelg = $true
            }
            elseif ( $hour -lt 6 -and $hour -gt 22 )
            {
                $nattHelg = $true
            } 
            else
            {
                $nattHelg = $false
            }
            if ( $Month -ge 1 -and $Month -le 4 -and $nattHelg)
            {
                $nettLeie = $NettleieNattRedusert
            }
            elseif ( $Month -ge 1 -and $Month -le 4 -and -not $nattHelg)
            {
                $nettLeie = $NettleieDagRedusert
            }
            elseif ( -not ($Month -ge 1 -and $Month -le 4) -and $nattHelg)
            {
                $nettLeie = $NettleieNatt
            }
            else
            {
                $nettLeie = $NettleieDag
            }
        }
        else
        {
            $nettLeie = 0
        }
        $supportNetto =  ($GjennomsnittsPris - ( $Grense * 1.25 ) ) * $Prosent / 100
        $grenseverdi = $supportNetto - $nettLeie
        $nettoPris = $pris - $grenseverdi
        [psobject]@{
            'Strømstøtte' = $supportNetto
            'Nettleie' = $nettLeie
            'Nullnivå' = $grenseverdi
            'NettoPris' = $nettoPris
        }
      
    }
    End
    {

    }
}