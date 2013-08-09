---
layout: notebook
title: simple-liquid-motor
---

# Liquid Rocket Motor Back Of The Envelope Calculations

How much power does it take to run a small liquid rocket motor? Is it hundreds of Watts, or killoWatts? Does it take 500 liters of fuel?

Just to get a feel for the problem space and what small motors might look and act like here are a bunch of simple calculations.

---

To start off let's import `math` and set $g_0$ to the standard value.

{% highlight python %}
from math import pi
g_0 = 9.8066
{% endhighlight %}
## Define The Motor

We want a ~2.5 kN LOX/kerosene motor. We can use the program [Rocket Propulsion Analysis](http://www.propulsion-analysis.com/) to do the basic thermodynamic and chemical equilibrium calculations for the given fuels. So we can start off with the following numbers:

{% highlight python %}
v_e = 2601.0   # m s-1    - Effective propellant velocity (from RPA)
T   = 2500.0   # N        - Thrust (set by us)
OF  =    2.56  #          - O/F Ratio, standard for LOX/kero
P   =  3.5e6   # Pa       - Chamber pressure (set by us)
O_r = 1146.0   # kg m-3   - Density of LOX
F_r =  819.0   # kg m-3   - Density of T-1 (rocket grade kero, used in RPA sim)
{% endhighlight %}
## Mass Flow Rate

Thrust is directly proportional to the effective velocity, $v_e$ and the mass flow rate of the motor, $\dot m$.

$$\begin{equation}\text T = \dot m v_e\end{equation}$$

So we can solve for total $\dot m$. Since we also know O/F (by mass) we can get out $\dot m_{ox}$ and $\dot m_f$ as well.

{% highlight python %}
mdot = T / v_e

mdot_O = mdot / (1 + (1/OF))
mdot_F = mdot / (1 + OF)
{% endhighlight %}
Using the density of the fluids involved we can find that

{% highlight python %}
flow_O = mdot_O / O_r  # m^3
flow_F = mdot_F / F_r  # m^3
print "We eat %0.2f L/s of LOX and %0.2f L/s of kerosene" % (flow_O * 1.0e3, flow_F * 1.0e3) # convert m3 to L
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> We eat 0.60 L/s of LOX and 0.33 L/s of kerosene
</pre>
</div>
## Motor Power

Knowing the total $\dot m$ and $v_e$ also gets us the motor power. This is rarely used in rocketry because it's much more meaningful and direct to deal with thrust in Newtons instead of 'power' in Watts. Still, it's an interesting aside.

The motor power is effectivly the work done by the exiting gas:

$$\begin{equation}\text{Pow}_{motor}= \frac{1}{2}\dot m {v_e}^2\end{equation}$$

{% highlight python %}
P_T = 0.5 * mdot * v_e**2
print "Motor ouput power: %0.1f MW" % (P_T / 1.0e6)
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> Motor ouput power: 3.3 MW
</pre>
</div>
## Burn Time

Let's take a guess that we need 50 seconds of burn time to get to a reasonable altitude. We can then calculate the total mass of volume of fuel. Assuming a ~6 inch diameter airframe we can guess at tank size too.

{% highlight python %}
t_bo = 50               # s    - Burn time
A_id =  0.146           # m    - airframe ID (6" OD, 1/8" walls)

Ox_m = (mdot_O * t_bo)  # kg
Fu_m = (mdot_F * t_bo)  # kg
Ox_v = (Ox_m/O_r)       # m3
Fu_v = (Fu_m/F_r)       # m3

h = (Ox_v + Fu_v)/(pi*(A_id/2.0)**2)  # Total tank length

print "Fuel for a %0.0f second burn time:" % t_bo
print "    LOX:        %0.1f Liters (%4.1f kg)" % (Ox_v * 1.0e3, Ox_m)
print "    Kerosene:   %0.1f Liters (%4.1f kg)" % (Fu_v * 1.0e3, Fu_m)
print "    Total prop: %0.1f Liters (%4.1f kg)" % ((Ox_v + Fu_v) * 1.0e3, Ox_m+Fu_m)
print "Propelent tank height at %0.0f mm OD: %0.1f m" % (A_id*1.0e3, h)
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> Fuel for a 50 second burn time:
<span class="prompt">&gt;</span>     LOX:        30.2 Liters (34.6 kg)
<span class="prompt">&gt;</span>     Kerosene:   16.5 Liters (13.5 kg)
<span class="prompt">&gt;</span>     Total prop: 46.6 Liters (48.1 kg)
<span class="prompt">&gt;</span> Propelent tank height at 146 mm OD: 2.8 m
</pre>
</div>
## Pump Power

Most interestingly we can guess at the pump shaft power nessisary for a motor of this class.

All pumps are less than ideal. So we always divide our moving propellant energy by a pump/motor efficiency scaler, $\eta$.

$$\begin{equation}\text{Pow}_{pump} = \frac{\Delta \text{P} Q}{\eta}\end{equation}$$

Where $\Delta\text P$ is the differental pressure (pump inlet -> outlet) and $Q$ is the fluid flowrate (m<sup>3</sup>&middot;s<sup>-1</sup>)

{% highlight python %}
nu = 0.6  # pump efficiency

Pow_O = (P*(mdot_O/O_r))/nu
Pow_F = (P*(mdot_F/F_r))/nu

print "Pump Stats:"
print "    Oxidizer pump shaft power: %0.1f kW" % (Pow_O / 1e3)
print "    Fuel pump shaft power:     %0.1f kW" % (Pow_F / 1e3)
print "    Total Power:               %0.1f kW" % ((Pow_O + Pow_F) / 1e3)
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> Pump Stats:
<span class="prompt">&gt;</span>     Oxidizer pump shaft power: 3.5 kW
<span class="prompt">&gt;</span>     Fuel pump shaft power:     1.9 kW
<span class="prompt">&gt;</span>     Total Power:               5.4 kW
</pre>
</div>
# Other Numbers

We can also make a stab at less important but fun numbers.

## Propellant Costs

Fuel is cheap. Insanely cheap. The best numbers I can find are bulk rates, so taking them and multiplying by 5 seems safe. The kerosene number is ~5$/gallon. Bascially pump prices. I hope these numbers a large overestimates. Still about a 200 times cheaper than AP!

{% highlight python %}
pc_O =  1.0 # $/kg
pc_F = 10.0 # $/kg

print "Price:"
print "    LOX:      $%0.2f" % (Ox_m*pc_O)
print "    Kerosene: $%0.2f" % (Fu_m*pc_F)
print "    Total:    $%0.2f" % ((Ox_m*pc_O) + (Fu_m*pc_F))
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> Price:
<span class="prompt">&gt;</span>     LOX:      $34.56
<span class="prompt">&gt;</span>     Kerosene: $135.00
<span class="prompt">&gt;</span>     Total:    $169.55
</pre>
</div>
## NAR Letter Code

What kind of motor is this?

{% highlight python %}
NS = T * t_bo  # Ns   - total impulse

l = 2.5
for i in xrange(26):
    if NS < l:
        letter = chr(ord('A')+i)
        break
    l = l*2
    
print "Motor letter designation: %s (%0.0f Ns)" % (letter, NS)
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> Motor letter designation: Q (125000 Ns)
</pre>
</div>
