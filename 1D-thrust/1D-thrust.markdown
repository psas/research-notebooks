---
layout: notebook
name: thrust
title: 1D Thrust
---

# 1D Thrust

Real spaceflight dynamics are complex. There are only a few basic forces involved, but some of them (namely air resistance) are non-conservative and tricky. In order to make a useful, accurate model of spaceflight you have to build a complex numerical approximation. However there is no need to be too complicated too quickly. A great place to start is to find an analytical solution for a rocket, solving for the height it will travel. Put everything in the 'up' axis and ignoring a ton of things will result in an easy place to start.

## The Simplest Case

The true simplest case is a point-mass rocket that is in free space with no gravity, air-resistance and has a simplified model of propulsion. Describing this situation mathematically results in the classic [Tsiolkovsky rocket equation](http://en.wikipedia.org/wiki/Tsiolkovsky_rocket_equation).

$$\begin{equation}\Delta v = v_e \ln\left(\frac{m_0}{m_f}\right)\end{equation}$$

Where

 - $\Delta v$ is the rocket's change in velocity
 - $v_e$ is the effective exaust velocity of the motor
 - $m_0$ and $m_f$ are the initial and final mass of the rocket

So calculating the motor burnout velocity of a rocket looks like this

{% highlight python %}
from math import log

v_e = 2345.0   # m/s
m_0 =  100.0   # kg
m_f =   40.0   # kg

dv = v_e*log(m_0/m_f)

print dv
{% endhighlight %}

<div class="output">
2148.70176624
</div>
