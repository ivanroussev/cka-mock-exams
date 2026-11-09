In namespace `checkout`, Deployment `cart-api` must scale automatically with CPU load.

Create a HorizontalPodAutoscaler named `cart-api` (API `autoscaling/v2`) that:

- targets Deployment `cart-api` and keeps between **2** and **8** replicas,
- aims for an average CPU utilisation of **65%**,
- when scaling **down**, uses a stabilization window of **180 seconds** and removes **at most 1 pod per 60 seconds**.

Scale-up behaviour stays at the default.
