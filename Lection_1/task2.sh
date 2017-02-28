perl -aF';' -lne 'if($F[4]>1048576){$x++;print$F[8]};$y++}{print"@{[0+$x]}/@{[0+$y]}"' file
