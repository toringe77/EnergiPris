Function Get-EnergiPris
{
    <#
        .SYNOPSIS
        Regner ut netto pris per kWh.
        .DESCRIPTION
        Funksjonen vil regne ut netto pris inkl. nettleie og str�mst�tte.
        .PARAMETER GjennomsnittsPris
        (Forel�pig) m�nedlig gjennomsnittspris
        .PARAMETER Pris
        Timespris n�.
        .PARAMETER LavestePris
        Laveste mulige pris p� str�mb�rsen (Satt til 0.01 kr). Denne brukes til � sette dagsprisen for resten av dagene i m�neden, om den skulle bli veldig lav.
        .PARAMETER IgnoreNettleie
        Utelat nettleie fra prisen.
        .PARAMETER NettleieDag
        Nettleie dagtid 2022
        .PARAMETER NettleieNatt
        Nettleie kveldstid og helg 2022
        .PARAMETER NettleieDagRedusert
        Nettleie dagtid, januar til april 2023 (redusert avgift)
        .PARAMETER NettleieNattRedusert
        Nettleie kveldstid og helg, januar til april 2023 (redusert avgift)
        .PARAMETER Prosent
        Str�mst�tteprosenten. For tiden 90%.
        .PARAMETER Grense
        Nedre grense for str�mst�tten. 0,7 kr i 2022 eksl. mva.
        .PARAMETER MND
        Overstyre m�ned (1-12)
        .PARAMETER Dag
        Overstyre dag (1-31)
        .PARAMETER Anno
        Overstyre �r.
        .PARAMETER Time
        Overstyre time p� dagen. 
        .INPUTS
        Ingen
        .OUTPUTS
        Powershell objekt med priser i NOK.
        .EXAMPLE
        PS> Get-EnergiPris -GjennomsnittsPris 3.6629 -Pris 1.4819
        
        Str�mst�tte                    : 2,50911
        Nettleie                       : 0,3739
        NettoPris                      : -0,65331
        Nullniv�                       : 2,13521
        Gjennomsnittspris Pessimistisk : 3,4272
        Str�mst�tte Pessimistisk       : 2,29698
        Nullnivp� Pessimistisk         : 1,92308
        Nettopris Pessimistisk         : -0,44118

        .EXAMPLE
        PS> Get-EnergiPris -GjennomsnittsPris 3.6629 -Pris 1.4819 -Dag 30 -Time 22

        Str�mst�tte                    : 2,50911
        Nettleie                       : 0,3739
        NettoPris                      : -0,65331
        Nullniv�                       : 2,13521
        Gjennomsnittspris Pessimistisk : 3,5451
        Str�mst�tte Pessimistisk       : 2,40309
        Nullnivp� Pessimistisk         : 2,02919
        Nettopris Pessimistisk         : -0,54729

        .EXAMPLE
        PS> Get-EnergiPris -GjennomsnittsPris 3.6629 -Pris 1.4819 -Dag 15 -Time 22 -MND 1 -Anno 2023

        Str�mst�tte                    : 2,50911
        Nettleie                       : 0,2904
        NettoPris                      : -0,73681
        Nullniv�                       : 2,21871
        Gjennomsnittspris Pessimistisk : 1,7775
        Str�mst�tte Pessimistisk       : 0,81225
        Nullnivp� Pessimistisk         : 0,52185
        Nettopris Pessimistisk         : 0,96005
  
        .LINK
        Most Recent Version: https://github.com/toringe77/EnergiPris
    #>


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
        [Alias("�r","Year")]
        [string]
        $Anno = (Get-Date).Year,
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
            $Ukedag = ( Get-date -Day $Dag -Month $MND -Year $Anno ).DayOfWeek
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
        if ( $supportNetto -lt 0 ) { $supportNetto = 0 }
        $grenseverdi = $supportNetto - $nettLeie
        $nettoPris = $pris - $grenseverdi

        # Calculate Last day of month and days left of month
        $lastDayOfMonth = ((Get-date -Day 1 -Month $MND ).AddMonths(1).AddDays(-1)).Day
        $numDaysLeft = $lastDayOfMonth - $Dag

        # Calculate average based on "worst case scenario" 
        $pessimistiskGjennomsnitt = [math]::round( (( $GjennomsnittsPris * $Dag + $numDaysLeft * $LavestePris ) / $lastDayOfMonth ),4 )
        $pessimistiskNetto =  ($pessimistiskGjennomsnitt - ( $Grense * 1.25 ) ) * $Prosent / 100
        if ( $pessimistiskNetto -lt 0 ) { $pessimistiskNetto = 0 }
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