---
layout: notebook
title: 
---


# Making an Open Rocket Motor

We need an .eng file for OpenRocket based on our initial guesses for a liquid rocket.

## Variables

We want to set **Thrust**, **Propellent Mass**, **Tank Material**. We will make assumtions about the $I_{sp}$ and O/F ratios. We'll also add in some fudge factors for take ullage and engine mass.

### Setup


{% highlight python %}
from math import pi

# Variables
Thrust   =  2000.0    # N       Thrust
M_prop   =    25.0    # kg      Propellent Mass
rho_tank =  4500.0    # kg/m^3  Tank densisty

# Assumptions
Isp      =   230.0    # s       Specific Impulse
OF       =     1.6    #         O/F ratio
r        =     0.0762 # m       Radius rocket

# Physics
g_0      =      9.81  # g       Standard gravity

# Chemestry
rho_lox  =   1141.0   # kg/m^3  Desity of LOX
rho_eth  =    852.3   # kg/m^3  Desity of Ethanol (with 70% H2O)
{% endhighlight %}

### Mass and Flow

Given the assumptions above we can solve the mass flow rate through the system


{% highlight python %}
# Total mass flow rate
mdot = Thrust / (g_0*Isp)

# Mass flow for each propllent
mdot_o = mdot / (1 + (1/OF))
mdot_f = mdot / (1 + OF)

# Propellent Mass
m_o = M_prop / (1 + (1/OF))
m_f = M_prop / (1 + OF)

print "Ox mass:   %0.1f kg" % m_o
print "Fuel mass: %0.2f kg" % m_f
print "Mass flow: %0.3f kg/s" % mdot
print "Ox flow:   %0.3f kg/s" % mdot_o
print "Fuel flow: %0.3f ks/s" % mdot_f
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> Ox mass:   15.4 kg
<span class="prompt">&gt;</span> Fuel mass: 9.62 kg
<span class="prompt">&gt;</span> Mass flow: 0.886 kg/s
<span class="prompt">&gt;</span> Ox flow:   0.545 kg/s
<span class="prompt">&gt;</span> Fuel flow: 0.341 ks/s
</pre>
</div>

### Tank Geometry

We'll model each tank as a cylinder. We're going to take a guess at the mass of propellant nessissary to run the rocket. We also know the diameter of finished rocket. So we can take a guess at the length of the tank $l_t$:

$$l_t = \frac{m_p}{\rho_p\pi r^2}$$

Where $m_p$ and $\rho_p$ are mass and densisty of the propellent and $r$ is the radius of the tank.


{% highlight python %}
def tank_length(m, rho, r):
    l = m / (rho*pi*r*r)
    # add a fudge for ullege
    l += l*0.1 # add 10%
    return l

l_o = tank_length(m_o, rho_lox, r)
l_f = tank_length(m_f, rho_eth, r)

print "Ox tank length:   %0.3f m" % l_o
print "Fuel tank length: %0.3f m" % l_f
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> Ox tank length:   0.813 m
<span class="prompt">&gt;</span> Fuel tank length: 0.680 m
</pre>
</div>

### Tank Mass


{% highlight python %}
def tank_mass(l, r, rho_tank):
    A = 2*pi*r*h + 2*pi*r*r
    return A
{% endhighlight %}

## Thrust Curve




{% highlight python %}

file_head = """<engine-database>
  <engine-list>
    <engine  mfg="PSAS" code="P10000-BS" Type="unspecified" dia="{diameter}." len="{length}."
    initWt="{total_mass}." propWt="{M_prop}." delays="0" auto-calc-mass="0" auto-calc-cg="0"
    avgThrust="{thrust}" peakThrust="{thrust}" throatDia="0." exitDia="0." Itot="{impulse}"
    burn-time="{burn_time}" massFrac="{m_frac}" Isp="{Isp}" tDiv="10" tStep="-1." tFix="1"
    FDiv="10" FStep="-1." FFix="1" mDiv="10" mStep="-1." mFix="1" cgDiv="10"
    cgStep="-1." cgFix="1">
    <comments>Made up</comments>
    <data>
""".format(**{'diameter': r*2,
              'length': 10,
              'total_mass': 100,
              'M_prop': M_prop,
              'thrust': Thrust,
              'burn_time': 12,
              'm_frac': 0.5,
              'impulse': 10000,
              'Isp': Isp,
    })

"""
      <eng-data  t="0." f="0." m="4959." cg="351."/>
"""

file_tail = """
    </data>
  </engine>
</engine-list>
</engine-database>"""

print file_head
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> <engine-database&gt;,
<span class="prompt">&gt;</span>   <engine-list&gt;,
<span class="prompt">&gt;</span>     <engine  mfg="PSAS" code="P10000-BS" Type="unspecified" dia="0.1524." len="10."
<span class="prompt">&gt;</span>     initWt="100." propWt="25.0." delays="0" auto-calc-mass="0" auto-calc-cg="0"
<span class="prompt">&gt;</span>     avgThrust="2000.0" peakThrust="2000.0" throatDia="0." exitDia="0." Itot="10000"
<span class="prompt">&gt;</span>     burn-time="12" massFrac="0.5" Isp="230.0" tDiv="10" tStep="-1." tFix="1"
<span class="prompt">&gt;</span>     FDiv="10" FStep="-1." FFix="1" mDiv="10" mStep="-1." mFix="1" cgDiv="10"
<span class="prompt">&gt;</span>     cgStep="-1." cgFix="1"&gt;,
<span class="prompt">&gt;</span>     <comments&gt;,Made up</comments&gt;,
<span class="prompt">&gt;</span>     <data&gt;,
<span class="prompt">&gt;</span> 
</pre>
</div>
