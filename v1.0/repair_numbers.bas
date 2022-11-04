Attribute VB_Name = "repair_numbers"
Sub repair_numbers()
Attribute repair_numbers.VB_ProcData.VB_Invoke_Func = "o\n14"
'
' repair_numbers Macro
'
' Keyboard Shortcut: Ctrl+o
'
    Columns("C:AD").Select
    Selection.NumberFormat = "General"
End Sub
