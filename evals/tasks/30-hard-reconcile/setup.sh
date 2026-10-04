cat > bank.csv <<'C'
Date,Description,Amount
02/03/2026,"Coffee, Main St","(4,50)"
03/03/2026,Salary,"3.200,00"
05/03/2026,Rent,"-1.150,00"
05/03/2026,"Groceries; weekly","-87,35"
06/03/2026,Transfer in,"50,00"
09/03/2026,Transfer in,"50,00"
10/03/2026,Refund,"20,00"
12/03/2026,Gym,"-29,99"
31/01/2026,Insurance,"-120,00"
14/03/2026,Book,"-15,00"
15/03/2026,Book,"-15,00"
20/03/2026,Fee,"(2,00)"
21/03/2026,Bonus,"1.234,56"
C
cat > ledger.csv <<'C'
date,memo,amount
2026-03-01,coffee,-4.50
2026-03-03,salary march,3200.00
2026-03-08,rent,-1150.00
2026-03-05,groceries,-87.35
2026-03-08,from savings,50.00
2026-03-07,from savings,50.00
2026-03-10,refund shoes,-20.00
2026-03-13,gym,-29.99
2026-02-02,insurance,-120.00
2026-03-16,book,-15.00
2026-03-13,book,-15.00
2026-03-22,fee,-2.00
2026-03-21,bonus,1234.65
2026-03-25,unknown,-9.99
C
