library(ggplot2)
library(gridExtra)

#Simulation

#rsp = 0.1
#dsp = 0.1
#rp = 0.4
#dp = 0.4


getpredis <- function(rdpre, r, c=0){
  if(c == 0){
    rr=r
    rd=r 
  }else if(c > 0){
    if (rdpre >= 0.5){
      rr = r + (rdpre - 0.5) * 2 * c * (1-r)
      rd = r - (rdpre - 0.5) * 2 * c * r
    }else{
      rr = r - (0.5 - rdpre) * 2 * c * r
      rd = r + (0.5 - rdpre) * 2 * c * (1-r)
    }
  }else if(c<0){
    if (rdpre > 0.5){
      rr = r + (rdpre - 0.5) * 2 * c * r
      rd = r - (rdpre - 0.5) * 2 * c * (1-r)
    }else {
      rr = r - (0.5 - rdpre) * 2 * c * (1-r)
      rd = r + (0.5 - rdpre) * 2 * c * r 
    }
  }
  rsp = rdpre*rr
  rp = rdpre - rsp
  dsp = (1-rdpre)*rd
  dp = (1-rdpre) - dsp
  return(c(rsp,rp,dp,dsp))
}

plotf <- function(n, npre, r,c) {
  d= data.frame(npreID = 1:npre, rdpre = sapply(rnorm(npre,sd=0.2)+0.5, function(x)max(min(0.99,x),0.01)), total=0, n_rsp=0, n_rp=0, n_dsp=0,n_dp=0)

  for(i in 1:n){
    pre = sample(npre,1)
    # construct distribution
    predis = getpredis(d[pre, 'rdpre'], r, c)
    d[pre, 'total'] = d[pre, 'total'] + 1
    iv = runif(1)
    if(iv<=predis[1]){d[pre, 'n_rsp'] = d[pre, 'n_rsp'] + 1}
    else if(iv<=sum(predis[1:2])){d[pre, 'n_rp'] = d[pre, 'n_rp'] + 1}
    else if(iv<=sum(predis[1:3])){d[pre, 'n_dp'] = d[pre, 'n_dp'] + 1}
    else{d[pre, 'n_dsp'] = d[pre, 'n_dsp'] + 1}
    
  }
  
  any(d['total'] != d['n_rsp'] + d['n_dsp'] + d['n_rp'] + d['n_dp'])
  
  d['p_rsp'] = d['n_rsp'] / (d['n_rsp'] + d['n_dsp'])
  d['p_rp'] = d['n_rp'] / (d['n_rp'] + d['n_dp'])
  
  d['x'] = d['p_rsp']
  d['y'] = d['p_rp'] - d['p_rsp']
  
  ggplot(d, aes(x,y)) +
    geom_point(col='blue',aes(size=total, col=rdpre), alpha=0.3) + 
    labs(x='percent of Reparblican straight per precint')
  return(d)
}

n = 300000
npre = 300
r = 0.2
c = 0.1

plotf2 <- function(d,c){
  p = ggplot(d, aes(x,y)) +
    geom_point(aes(size=total, col=rdpre), alpha=1) + 
    labs(x='Reparblican straight Votes %',y="Trump Votes % - Republican straight Votes %", col='Rep/Trump%', size="#Votes") + 
    scale_colour_gradient2(low="blue",mid="white",high="red", midpoint = 0.5) +
    geom_text(aes(x=0,y=-0.1,label=paste0("c=",c))) + 
    scale_x_continuous(limits = c(0,1))
  return(p)
}


c=0.1
d01 = plotf(n, npre, r, c)
p01 = plotf2(d01,c)
  
c=0.5
d05 = plotf(n, npre, r, c)
p05 = plotf2(d05,c)

c=0.9
d09 = plotf(n, npre, r, c)
p09 = plotf2(d09,c)

c = -0.9
dn09 = plotf(n, npre, r, c)
pn09 = plotf2(dn09,c)

c = -0.5
dn05 = plotf(n, npre, r, c)
pn05 = plotf2(dn05,c)
  
c = -0.1
dn01 = plotf(n, npre, r, c)
pn01 = plotf2(dn01,c)

c = 0
d0 = plotf(n, npre, r, c)
p0 = plotf2(d0,c)

pdf("7-pic.pdf", width = 28, height = 18)
grid.arrange(pn09,pn05,pn01,p0,p01,p05,p09, ncol = 3)
dev.off()

pdf("3-pic.pdf", width = 28, height = 7)
grid.arrange(pn01,p0,p01, ncol = 3)
dev.off()


