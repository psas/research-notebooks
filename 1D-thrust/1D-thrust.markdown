---
layout: notebook
title: 1D-thrust
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

v_e = 2000.0   # m/s
m_0 =  100.0   # kg
m_f =   40.0   # kg

dv = v_e*log(m_0/m_f)

print "%0.0f m/s" % dv
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> 1833 m/s
</pre>
</div>

## Add Gravity

With gravity the story is a little different.

$$\begin{equation}v_{bo} = v_e \ln\left(\frac{m_0}{m_f}\right) - gt_{bo} + v_0\end{equation}$$

The $-gt_{bo}$ term means that we _lose_ performance the longer we burn the rocket! This is explained by the idea that lifting unburnt fuel is energy expensive. Ideally the entire rocket burn would be impulsive i.e. as short of a burn time as possible. Interestingly if there is no gravity, it doesn't matter how long we take to burn the rocket, we'll still achieve the same delta-v.

Lets look at delta-v again with a similar rocket with a 10 second burn time.


{% highlight python %}
t_bo = 10.0     # s
g    =  9.8066  # m/s/s

dv = v_e*log(m_0/m_f) - (g*t_bo)

print "%0.0f m/s" % dv
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> 1735 m/s
</pre>
</div>

We don't get as far, which is to be expected because we're in a gravity well!

## Rocket Height

Since we're in a gravity well it now makes sense to talk about rocket height. In order to see how far we get during the rocket burn we have to integrate the velocity equation to get height.

$$\begin{equation}h_{bo} = -t_{bo}v_e\frac{\ln\left(\frac{m_0}{m_f}\right)}{\left(\frac{m_0}{m_f}-1\right)}+t_{bo}v_e-\frac{1}{2}gt^2\end{equation}$$

And then we know that the final height is just how far it continues with the kinetic energy it had at burnout.

$$h_f = \frac{v_{bo}^2}{2g} + h_{bo}$$

$$\begin{equation}h_f = \frac{\left(v_e\ln\left(\frac{m_0}{m_f}\right)-gt_{bo}\right)^2}{2g} - t_{bo}v_e\frac{\ln\left(\frac{m_0}{m_f}\right)}{\left(\frac{m_0}{m_f}-1\right)}+t_{bo}v_e-\frac{1}{2}gt^2\end{equation}$$


