; ========================================================
; MonnyOS - Monitor Library Routines
; ========================================================
; Create By: RicardoMC310
; Version: 1.0.0
; ========================================================

%ifndef __KERNEL_MONITOR_INC__
%define __KERNEL_MONITOR_INC__


segment .text
; ________________________________________________________
; Directives and Inclusions ______________________________

%include "monny/common/details.inc"

; End - Directives and Inclusions_________________________



; ________________________________________________________
; Variables ______________________________________________

; End - Variables ________________________________________



; ________________________________________________________
; API Functions __________________________________________

extern monitor_init
extern monitor_draw_background
extern monitor_print_string
extern monitor_move_cursor
extern monitor_move_shift_right_cursor
extern monitor_effect

; End - API Functions ____________________________________


%endif