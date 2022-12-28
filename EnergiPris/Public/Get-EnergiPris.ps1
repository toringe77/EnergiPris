Function Get-EnergiPris
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
        [decimal]
        $LavestePris = 0.01,
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
        [Alias("Month","M�ned")]
        [int]
        $MND = (get-date).Month,
        [int]
        $Dag = (Get-Date).Day,
        [Alias("DayOfWeek")]
        [string]
        $Ukedag = (get-date).Dayofweek,
        [Alias("Hour")]
        [int]
        $Time = (get-date).Hour
    )
    Begin
    {
        
    }
    Process
    {
        if ( -not $IgnoreNettleie )
        {
            if ( $Ukedag -eq "Saturday" -or $Ukedag -eq "Sunday" -or $Ukedag -eq "L�rdag" -or $Ukedag -eq "S�ndag" )
            {
                $nattHelg = $true
            }
            elseif ( $hour -lt 6 -or $hour -gt 22 )
            {
                $nattHelg = $true
            } 
            else
            {
                $nattHelg = $false
            }
            if ( $MND -ge 1 -and $MND -le 4 -and $nattHelg)
            {
                $nettLeie = $NettleieNattRedusert
            }
            elseif ( $MND -ge 1 -and $MND -le 4 -and -not $nattHelg)
            {
                $nettLeie = $NettleieDagRedusert
            }
            elseif ( -not ($MND -ge 1 -and $MND -le 4) -and $nattHelg)
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
        # Calculate cost based on current average.
        $supportNetto =  ($GjennomsnittsPris - ( $Grense * 1.25 ) ) * $Prosent / 100
        $grenseverdi = $supportNetto - $nettLeie
        $nettoPris = $pris - $grenseverdi

        # Calculate Last day of month and days left of month
        $lastDayOfMonth = ((Get-date -Day 1 -Month $MND ).AddMonths(1).AddDays(-1)).Day
        $numDaysLeft = $lastDayOfMonth - $Dag

        # Calculate average based on "worst case scenario" 
        $pessimistiskGjennomsnitt = [math]::round( (( $GjennomsnittsPris * $Dag + $numDaysLeft * $LavestePris ) / $lastDayOfMonth ),4 )
        $pessimistiskNetto =  ($pessimistiskGjennomsnitt - ( $Grense * 1.25 ) ) * $Prosent / 100
        $pessimistiskGrenseverdi = $pessimistiskNetto - $nettLeie
        $pessimistiskNettoPris = $pris - $pessimistiskGrenseverdi

        [pscustomobject]@{
            'Str�mst�tte' = $supportNetto
            'Nettleie' = $nettLeie
            'Nullniv�' = $grenseverdi
            'NettoPris' = $nettoPris
            'Gjennomsnittspris Pessimistisk' = $pessimistiskGjennomsnitt
            'Str�mst�tte Pessimistisk' = $pessimistiskNetto
            'Nullnivp� Pessimistisk' = $pessimistiskGrenseverdi
            'Nettopris Pessimistisk' = $pessimistiskNettoPris
        } | Select-Object 'Str�mst�tte','Nettleie','NettoPris','Nullniv�','Gjennomsnittspris Pessimistisk','Str�mst�tte Pessimistisk','Nullnivp� Pessimistisk','Nettopris Pessimistisk'
    }
    End
    {

    }
}