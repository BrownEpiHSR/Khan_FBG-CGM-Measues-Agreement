install.packages("statpsych")
library(statpsych)

#interval level
ci.phi(0.05, 5,2,32,750)


# ci.phi(0.05, 5,2,32,750)
# Estimate         SE        LL        UL
# 0.2986711 0.08970544 0.1145159 0.4629812

interval<-ci.phi(0.05, 5,2,32,750)

interval_rounded<-round(interval, 2)
print(interval_rounded)

# Estimate   SE   LL   UL
# 0.3 0.09 0.11 0.46

#day level
ci.phi(0.05, 5,2, 35,382)

day<-ci.phi(0.05, 5,2, 35,382)
day_rounded<-round(day, 2)
print (day_rounded)
# Estimate   SE  LL   UL
# 0.27 0.09 0.1 0.44

