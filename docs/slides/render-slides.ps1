Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$ink = '#173E35'; $green = '#357D64'; $muted = '#729087'; $paper = '#F5F7F2'; $line = '#D8E4DB'
function Brush($c) { [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml($c)) }
function Box($x,$y,$w,$h,$c='#FFFFFF') { $b=Brush $c; $g.FillRectangle($b,$x,$y,$w,$h); $b.Dispose() }
function Label($s,$x,$y,$size=25,$c=$ink) { $f=[System.Drawing.Font]::new('Segoe UI',$size); $b=Brush $c; $g.DrawString($s,$f,$b,$x,$y); $b.Dispose(); $f.Dispose() }
function Arrow($x,$y,$xx,$yy) { $p=[System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml($green),5); $p.CustomEndCap=[System.Drawing.Drawing2D.AdjustableArrowCap]::new(5,6); $g.DrawLine($p,$x,$y,$xx,$yy); $p.Dispose() }
function Phone($x,$y,$w=330,$h=620,$title='Today') { Box $x $y $w $h $ink; Box ($x+8) ($y+8) ($w-16) ($h-16) '#FFFFFF'; Box ($x+8) ($y+8) ($w-16) 85 '#E1EDE3'; Label $title ($x+30) ($y+26) 27 }
function Tile($x,$y,$w,$name,$value) { Box $x $y $w 95 '#EAF1E8'; Label $name ($x+18) ($y+10) 20; Label $value ($x+18) ($y+40) 27 }
function Begin { $script:bmp=[System.Drawing.Bitmap]::new(1600,900); $script:g=[System.Drawing.Graphics]::FromImage($bmp); $g.SmoothingMode='AntiAlias'; $g.TextRenderingHint='AntiAliasGridFit'; $g.Clear([System.Drawing.ColorTranslator]::FromHtml($paper)) }
function Save($n) { $bmp.Save((Join-Path $PSScriptRoot ('exp-{0:00}.jpg' -f $n)),[System.Drawing.Imaging.ImageFormat]::Jpeg); $g.Dispose(); $bmp.Dispose() }

# Values flow into the function; nullable note remains empty.
Begin
Box 90 160 440 560
Label 'Greek yogurt' 125 190 38
Tile 125 280 370 'Calories' '280 kcal'
Tile 125 395 370 'Protein' '20.5 g'
Box 125 515 370 95 '#F2F3EF'; Label 'Note' 143 526 20; Label '—' 143 556 27 $muted
Arrow 555 350 680 350
Box 700 245 360 240 '#E1EDE3'; Label '280 + 120' 733 300 45; Label '=' 840 380 38
Arrow 1085 350 1190 350
Box 1220 245 290 240 $green; Label '400' 1265 285 70 '#FFFFFF'; Label 'kcal' 1300 390 28 '#FFFFFF'
Save 1

# Composition: nested regions map to the rendered screen.
Begin
Box 95 140 640 620 '#DFEAE1'; Label 'Today' 130 160 32
Box 125 240 580 480 '#FFFFFF'; Label 'Daily energy' 155 260 26
Box 155 335 520 155 '#EDF3EA'; Tile 170 350 235 'Calories' '400 kcal'; Tile 420 350 235 'Water' '2 glasses'
Box 155 520 520 160 '#EDF3EA'; Label 'Breakfast' 175 535 22; Label 'Greek yogurt' 175 580 27; Label '280 kcal' 175 625 22
Arrow 770 450 910 450
Phone 980 140 450 620
Label 'Daily energy' 1010 250 26; Tile 1010 310 185 'Calories' '400 kcal'; Tile 1210 310 185 'Water' '2 glasses'
Label 'Breakfast' 1010 460 22; Tile 1010 510 385 'Greek yogurt' '280 kcal'
Save 2

# Same cards, one column below 720 and two from 720 onward.
Begin
Label '390 px' 235 75 28; Label '900 px' 1060 75 28
Phone 155 140 350 650
Tile 185 260 290 'Calories' '400 kcal'; Tile 185 375 290 'Protein' '20.5 g'; Tile 185 490 290 'Carbs' '42 g'; Tile 185 605 290 'Fat' '12 g'
Arrow 540 455 755 455; Label '720 px' 585 395 22
Phone 810 200 660 520
Tile 845 330 280 'Calories' '400 kcal'; Tile 1150 330 280 'Protein' '20.5 g'; Tile 845 450 280 'Carbs' '42 g'; Tile 1150 450 280 'Fat' '12 g'
Save 3

# Named navigation and the resulting route stack.
Begin
Phone 115 130 360 610
Tile 145 260 300 'Daily energy' '400 kcal'; Box 145 570 300 70 $green; Label 'Insights' 230 582 25 '#FFFFFF'; Label '/' 275 760 30
Arrow 515 350 1050 350; Label '/insights' 680 290 28
Phone 1100 130 360 610 'Insights'
Label 'Calories' 1130 260 23
foreach($i in 0..4) { $hh=@(80,150,110,210,170)[$i]; Box (1140+$i*55) (540-$hh) 32 $hh $green }
Label '/insights' 1185 760 28
Arrow 1050 630 515 630; Label '‹' 770 555 50
Box 625 425 350 125 '#E1EDE3'; Label '/insights' 655 430 23; Label '/' 655 485 23
Save 4

# Local selection rebuild plus shared goals notifying two views.
Begin
Box 90 95 570 230; Label 'Breakfast' 120 135 27; Box 355 130 240 65 $green; Label 'Lunch' 405 141 27 '#FFFFFF'; Label 'Lunch' 120 235 34
Arrow 700 215 890 215
Box 940 95 570 230; Box 970 130 240 65 '#EAF1E8'; Label 'Lunch' 1020 141 27; Tile 970 215 500 'Lunch' 'Greek yogurt'
Box 610 410 380 140 $green; Label '2,000 kcal' 665 445 40 '#FFFFFF'
Arrow 655 570 410 655; Arrow 945 570 1190 655
Tile 165 675 490 'Today · goal' '2,000 kcal'; Tile 945 675 490 'Insights · goal' '2,000 kcal'
Save 5

# One reusable row renders label and rounded value in each instance.
Begin
Box 120 210 430 430 '#E1EDE3'; Label 'Protein' 155 255 32; Label '20.5' 155 330 50; Box 155 445 350 90 $green; Label '21 g' 260 460 35 '#FFFFFF'
Arrow 595 425 855 425
Phone 925 140 520 620 'Nutrients'
Tile 960 265 450 'Protein' '21 g'; Tile 960 385 450 'Carbs' '42 g'; Tile 960 505 450 'Fat' '12 g'
Save 6

# Invalid input cannot save; valid input can fail and retry intact.
Begin
Phone 70 210 360 510 'Add food'; Label 'Food name' 100 330 21; Box 100 380 300 55 '#FFF1EC'; Label 'Enter a food name' 100 445 20 '#B84631'; Box 100 585 300 60 '#E3E7E0'; Label 'Save' 205 594 24
Arrow 465 455 600 455
Phone 640 210 360 510 'Add food'; Label 'Food name' 670 330 21; Box 670 380 300 55 '#EAF1E8'; Label 'Greek yogurt' 680 388 23; Box 670 585 300 60 $green; Label 'Save' 775 594 24 '#FFFFFF'
Arrow 1035 455 1150 455
Box 1190 180 340 170 '#E1EDE3'; Label 'Greek yogurt' 1220 210 27; Label '✓' 1315 260 40 $green
Box 1190 490 340 230 '#FFF1EC'; Label 'Greek yogurt' 1210 515 27; Label 'Could not save.' 1210 570 22 '#B84631'; Box 1220 625 280 65 $green; Label 'Try again' 1270 637 24 '#FFFFFF'
Arrow 1150 420 1190 295; Arrow 1150 490 1190 585
Save 7
