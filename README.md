## Overview
If any locomotive or wagon is destroyed the train it belongs to is brought to an immediate halt and a ghost is created. This ghost contains by default requests for all fuel and equipment that was inside the destroyed rolling stock. Inventory filters and limits are saved and restored as well. As soon as the train is complete again it will be set to automatic mode, if it was in that mode originally.


## Settings
The following map settings are available:

* Automatically enable automatic mode (trains will be set to automatic mode again as soon as all entity ghosts were built). Default = true
* Create item requests for destroyed equipment. Default = true
* Create item requests for fuel. Default = true
* Name of the fuel that should be requested (if left empty the destroyed fuel will be requested). Default = empty
* How much of the fuel should be requested. Default = 1


## Known issues
* Locomotives sometimes don't have the right orientation.
* The check whether a train is complete again is relatively simple. It doesn't wait for all item requests to be fulfilled and can't tell the difference between different entities of the same type.
* Equipment is inserted into cargo inventory first and only moved into the grid if the item request is fulfilled completely or otherwise destroyed.
* The item request icons in ghosts for wagons are, unlike for locomotives, not grouped.
