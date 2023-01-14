Function Get-EnergiPris
{
    <#
        .SYNOPSIS
        Regner ut netto pris per kWh.
        .DESCRIPTION
        Funksjonen vil regne ut netto pris inkl. nettleie og strømstøtte.
        .PARAMETER Pris
        Timespris nå.
        .PARAMETER GjennomsnittsPris
        (Foreløpig) månedlig gjennomsnittspris
        .PARAMETER Offline
        Ikke hent månedlig gjennomsnittspris fra web, selv om Gjennomsnittspris ikke er satt.
        .PARAMETER LavestePris
        Laveste mulige pris på strømbørsen (Satt til 0.01 kr). Denne brukes til å sette dagsprisen for resten av dagene i måneden, om den skulle bli veldig lav.
        .PARAMETER IgnoreNettleie
        Utelat nettleie fra prisen.
        .PARAMETER TekstResultat
        Skriv ut resultatet i tekst.
        .PARAMETER NettleieDag
        Nettleie dagtid 2022
        .PARAMETER NettleieNatt
        Nettleie kveldstid og helg 2022
        .PARAMETER NettleieDagRedusert
        Nettleie dagtid, januar til april 2023 (redusert avgift)
        .PARAMETER NettleieNattRedusert
        Nettleie kveldstid og helg, januar til april 2023 (redusert avgift)
        .PARAMETER Prosent
        Strømstøtteprosenten. For tiden 90%.
        .PARAMETER Grense
        Nedre grense for strømstøtten. 0,7 kr i 2022 eksl. mva.
        .PARAMETER MND
        Overstyre måned (1-12)
        .PARAMETER Dag
        Overstyre dag (1-31)
        .PARAMETER Anno
        Overstyre år.
        .PARAMETER Time
        Overstyre time på dagen. 
        .INPUTS
        Ingen
        .OUTPUTS
        Powershell objekt med priser i NOK.
        .EXAMPLE
        PS> Get-EnergiPris -GjennomsnittsPris 3.6629 -Pris 1.4819
        
        Strømstøtte                    : 2,50911
        Nettleie                       : 0,3739
        NettoPris                      : -0,65331
        Nullnivå                       : 2,13521
        Gjennomsnittspris Pessimistisk : 3,4272
        Strømstøtte Pessimistisk       : 2,29698
        Nullnivpå Pessimistisk         : 1,92308
        Nettopris Pessimistisk         : -0,44118

        .EXAMPLE
        PS> Get-EnergiPris -GjennomsnittsPris 3.6629 -Pris 1.4819 -Dag 30 -Time 22

        Strømstøtte                    : 2,50911
        Nettleie                       : 0,3739
        NettoPris                      : -0,65331
        Nullnivå                       : 2,13521
        Gjennomsnittspris Pessimistisk : 3,5451
        Strømstøtte Pessimistisk       : 2,40309
        Nullnivpå Pessimistisk         : 2,02919
        Nettopris Pessimistisk         : -0,54729

        .EXAMPLE
        PS> Get-EnergiPris -GjennomsnittsPris 3.6629 -Pris 1.4819 -Dag 15 -Time 22 -MND 1 -Anno 2023

        Strømstøtte                    : 2,50911
        Nettleie                       : 0,2904
        NettoPris                      : -0,73681
        Nullnivå                       : 2,21871
        Gjennomsnittspris Pessimistisk : 1,7775
        Strømstøtte Pessimistisk       : 0,81225
        Nullnivpå Pessimistisk         : 0,52185
        Nettopris Pessimistisk         : 0,96005
  
        .LINK
        Most Recent Version: https://github.com/toringe77/EnergiPris
    #>


    [cmdletbinding()]
    param(
        [Parameter(Position=0)]
        [Alias("Brutto","BruttoPris")]
        [decimal]
        $Pris,
        [Alias("AveragePrice")]
        [decimal]
        $GjennomsnittsPris,
        [switch]
        $Offline,
        [decimal]
        $LavestePris = 0.01,
        [switch]
        $IgnoreNettleie,
        [switch]
        $TekstResultat,
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
        [Alias("Month","Måned")]
        [int]
        $MND = (get-date).Month,
        [int]
        $Dag = (Get-Date).Day,
        [Alias("År","Year")]
        [string]
        $Anno = (Get-Date).Year,
        [Alias("Hour")]
        [int]
        $Time = (get-date).Hour
    )
    Begin
    {
        $cacheFile = "$($env:temp)\energipriscache.txt"
        if (-not $Gjennomsnittspris)
        {
            
            if (Test-Path $cacheFile )
            {
                $fileDate = [datetime](get-childitem $cacheFile | Select-Object -ExpandProperty LastWriteTime ) | get-date -Format "ddMMyyyy"
                if ($fileDate -eq (get-date -format "ddMMyyyy"))
                {
                    $GjennomsnittsPris = (get-content $cacheFile) / 100
                }
                else 
                {
                    $GjennomsnittsPris = $null
                }
            }
            if (-not ($GjennomsnittsPris) -and -not ($Offline))
            {
                Write-Warning "Henter priser fra https://elwin.ge.no/prishistorikk/PrisDiagram_NO1.html"
                $webReq = Invoke-WebRequest https://elwin.ge.no/prishistorikk/PrisDiagram_NO1.html -UseBasicParsing -DisableKeepAlive -ErrorAction Stop
                $webReqMatches = $webReq.content | select-string "Snittpris hittil denne m.ned: <b>(.{1,4})<\/b>"
                $GjennomsnittsPrisOre = $webReqMatches.matches.groups[1].value
                $GjennomsnittsPrisOre | Out-File $cacheFile
                $GjennomsnittsPris = $GjennomsnittsPrisOre / 100
            }
        }

    }
    Process
    {
        if (-not $GjennomsnittsPris)
        {
            Write-host "Trenger Gjennomsnittspris. Kunne ikke hente fra cache eller fra web."
            Return
        }
        if ( -not $IgnoreNettleie )
        {
            $Ukedag = ( Get-date -Day $Dag -Month $MND -Year $Anno ).DayOfWeek
            if ( $Ukedag -eq "Saturday" -or $Ukedag -eq "Sunday" -or $Ukedag -eq "Lørdag" -or $Ukedag -eq "Søndag" )
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
        $stromPris = $pris - $supportNetto
        $nettoPris = $stromPris + $nettLeie
        $grenseverdi = $supportNetto - $nettLeie
        
        # Calculate what the actual % is
        $tempReellPris = ($Pris - ( $Grense * 1.25 ) )
        if ($tempReellPris -lt 0)
        {
            $reellProsent = 0
        }
        else 
        {
            $reellProsent =  [math]::round(($supportNetto / $tempReellPris * 100),2)
        }
        $reellTotalProsent = [math]::round(((1-($stromPris/$pris)) * 100),2)

        # Calculate Last day of month and days left of month
        $lastDayOfMonth = ((Get-date -Day 1 -Month $MND ).AddMonths(1).AddDays(-1)).Day
        $numDaysLeft = $lastDayOfMonth - $Dag

        # Calculate average based on "worst case scenario" 
        $pessimistiskGjennomsnitt = [math]::round( (( $GjennomsnittsPris * $Dag + $numDaysLeft * $LavestePris ) / $lastDayOfMonth ),4 )
        $pessimistiskSupportNetto =  ($pessimistiskGjennomsnitt - ( $Grense * 1.25 ) ) * $Prosent / 100
        if ( $pessimistiskSupportNetto -lt 0 ) { $pessimistiskSupportNetto = 0 }
        $pessimistiskStromPris = $pris - $pessimistiskSupportNetto
        $pessimistiskGrenseverdi = $pessimistiskSupportNetto - $nettLeie
        $pessimistiskNettoPris = $pris - $pessimistiskGrenseverdi

        # Calculate the worst case scenario actual % support
        if ($tempReellPris -lt 0)
        {
            $pessimistiskReellProsent =  0
        }
        else {
            $pessimistiskReellProsent =  [math]::round(($pessimistiskSupportNetto / $tempReellPris * 100),2)
        }
        $pessimistiskReellTotalProsent = [math]::round(((1-($pessimistiskStromPris / $pris)) * 100),2) 
        if ($TekstResultat)
        {
            if ($reellProsent -eq 0)
            {
                $reellTekst = ""
            }
            else 
            {
                $reellTekst = "vil da i realiteten være $($reellProsent)%, og "
            }
            if ($supportNetto -gt 0)
            {
                $stotteTekst = "støtter staten med $supportNetto kr/kWh. Strømstøtten $($reelltext)tilsvarer $($reellTotalProsent)% av prisen."

            }
            else 
            {
                $stotteTekst = "vil ikke staten betale ut noe da strømstøtten bortfaller."
            }
            if ($pessimistiskReellProsent -gt 0)
            {
                $pessimistiskStottetekst = "vil i realiteten bli $($pessimistiskReellProsent)%, og "

            }
            else 
            {
                $pessimistiskStottetekst = ""
            }
            if ($pessimistiskSupportNetto -gt 0)
            {
                $pessimistiskTekst = "og strømstøtten $pessimistiskSupportNetto kWh. Strømstøtten $($pessimistiskStottetekst)tilsvarer $($pessimistiskReellTotalProsent)% av strømprisen."
            }
            else 
            {
               $pessimistiskTekst = "men strømstøtten bortfaller."
            }

            "Med en pris på $Pris kr/kWh og månedlig gjennomsnittspris $GjennomsnittsPris kr/kWh, $stotteTekst Hvis dagsprisen blir $LavestePris kr/kWh resten av måneden ($numDaysLeft dager), blir gjennomsnittet $pessimistiskGjennomsnitt kr/kWh, $pessimistiskTekst Netto pris vil bli $nettoPris kr/kWh med dagens gjennomsnittspris. $pessimistiskNettoPris kr/kWh hvis dagsprisen resten av måneden blir $LavestePris kr/kWh. En tjener penger når prisen er under $grenseverdi kr/kWh med dagens gjennomsnitt, og $pessimistiskGrenseverdi kr/kWh, hvis dagsprisen resten av måneden blir $LavestePris kr/kWh."
        }
        else 
        {
            [pscustomobject]@{
                'Gjennomsnittspris' = $GjennomsnittsPris
                'Strømstøtte' = $supportNetto
                'Nettleie' = $nettLeie
                'Nullnivå' = $grenseverdi
                'Netto strømpris' = $stromPris
                'Reell strømstøtteprosent' = $reellProsent
                'Reell totalprosent' = $reellTotalProsent
                'Netto totalpris' = $nettoPris
                'Gjennomsnittspris Pessimistisk' = $pessimistiskGjennomsnitt
                'Strømstøtte Pessimistisk' = $pessimistiskSupportNetto
                'Netto strømpris Pessimistisk' = $pessimistiskStromPris
                'Reell strømstøtteprosent Pessimistisk' = $pessimistiskReellProsent
                'Reell totalprosent Pessimistisk' = $pessimistiskReellTotalProsent
                'Nullnivpå Pessimistisk' = $pessimistiskGrenseverdi
                'Netto totalpris Pessimistisk' = $pessimistiskNettoPris
            } | Select-Object 'Gjennomsnittspris','Strømstøtte','Reell strømstøtteprosent','Reell totalprosent','Nettleie','Netto strømpris','Netto totalpris','Nullnivå','Gjennomsnittspris Pessimistisk','Strømstøtte Pessimistisk','Reell strømstøtteprosent Pessimistisk','Reell totalprosent Pessimistisk','Netto strømpris Pessimistisk','Netto totalpris Pessimistisk','Nullnivpå Pessimistisk'
        }
    }
    End
    {

    }
}