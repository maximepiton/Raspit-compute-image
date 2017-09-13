;;; TO ALTER RESSURE LEVEL PLOT SECTION
; PAULS - Change limits for feet/min

; NB: opts_bparam for contours
;     opts_w      for wind barbs

if( Region .eq. "UK2+1" ) then
    opts_bparam@ContourParameters = (/ -450., 450., 50. /)
else
    opts_bparam@ContourParameters = (/ -250., 250., 50. /)
end if


