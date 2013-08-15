---
layout: notebook
title: cubesat-linkbudget
---

# Cubesat Link Budget

What if we were to use WiFi on a cubesat? Is this even possible?

We need to know how much power we will have to use on the cubsat. This depends primarily on four things:

 - Distance between devices
 - Gain of the antennas
 - Minimum receive power allowable
 - Frequency

The so-called [Friis transmission equation](http://en.wikipedia.org/wiki/Friis_transmission_equation) is useful for determining the power recieved at one antenna assuming ideal conditions and free-space path loss between the two:

$$\begin{equation}P_r = P_t+G_t+G_r+20 \log_{10} \left( \frac{\lambda}{4\pi R}\right)\end{equation}$$

We can set some univseral constants and and handy conversion utility right away

{% highlight python %}
from math import pi, log10, sqrt
c    = 299792458.0   # m/s   Speed of light
R_e  =   6371000.0   # m     Mean radius of Earth

def db2w(db):
    'Convert dBm to Watts'
    return 0.001*pow(10,db/10.0)
{% endhighlight %}
## Define a cubesat

### Orbit

The distance (slant range) of the cubesat will depend on what orbit we end up in. Lets assume that we're in a circular orbit at 400 km (similar to the ISS)

{% highlight python %}
h = 400e3   # m   Orbit height above Earth's surface
{% endhighlight %}
We can find the best and worst case scenearios for the distance to the sat. Best case is directly overhead, the other is right on the horizon

{% highlight python %}
R_best = h
R_worst = sqrt((R_e+h)**2 - R_e**2)

print "Max range: %0.0f km, Min range: %0.0f km" % (R_worst/1.0e3, R_best/1.0e3)
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> Max range: 2293 km, Min range: 400 km
</pre>
</div>
### Band

FCC Part 97 lets us use about 50 MHz of the 2.4 GHz specturm for space trasminsions. This overlaps well with 802.11 channel ~4

So lets set our frequency there, and we need at least -95 dBm on the revceive side

{% highlight python %}
f = 2427e6   # Hz   carrier center frequency (channel 4)
Pr = -95     # dBm  Power at recieve antenna

l = c/f      # m    wavength of f

print "%0.1f cm band, one 1/4 wavelength = %0.2f mm" % ((l * 100), (l/4.0)*1000)
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span> 12.4 cm band, one 1/4 wavelength = 30.88 mm
</pre>
</div>
## Scenarios

We want to look at a couple of different power and antenna scenarios. Lets define one that is 'super ham' where we have a big dish on the ground. This is unlikely to be replicated by many amateurs, but at least we will be able to recieve the signal. The other will be 'super sat' which will be much harder to construct, but may allow more modest ground equipment. The intermediat solution doesn't do anything fancy on either side. 

For each scenario we'll define the gain of each antenna, `Gt` gain at the cubesat and `Gr`, gain on the ground

{% highlight python %}
scenarios = [
    {'name': "Super Ham",       'Gt':  0, 'Gr': 30},
    {'name': "Normal",          'Gt':  6, 'Gr':  6},
    {'name': "Super Satellite", 'Gt': 15, 'Gr':  6},
]
{% endhighlight %}
# Results

Now we can look at what happens in each case

{% highlight python %}
for scenario in scenarios:
    dBm_best  = Pr - scenario['Gr'] - scenario['Gt'] - (20*log10(l/(4*pi*R_best)))
    dBm_worst = Pr - scenario['Gr'] - scenario['Gt'] - (20*log10(l/(4*pi*R_worst)))

    print "%25s: Overhead: %6.1f W (%2.0f dBm),  Worst: %6.1f W (%2.0f dBm)" % (scenario['name'], db2w(dBm_best), dBm_best, db2w(dBm_worst), dBm_worst)
{% endhighlight %}

<div class="output">
<pre>
<span class="prompt">&gt;</span>                 Super Ham: Overhead:    0.5 W (27 dBm),  Worst:   17.2 W (42 dBm)
<span class="prompt">&gt;</span>                    Normal: Overhead:   33.0 W (45 dBm),  Worst: 1085.5 W (60 dBm)
<span class="prompt">&gt;</span>           Super Satellite: Overhead:    4.2 W (36 dBm),  Worst:  136.7 W (51 dBm)
</pre>
</div>
## Discusion

Clearly we need some pretty good gain. The nothing special case requires kW at the satellite (this is laughable).  Even the super sat is not very good without serious gain on the ground. We're probably not going to get out of having a dish.

On the other hand, in the super ham version we can get away with only about one Watt while being able to recieve for some period of time during an overhead pass.