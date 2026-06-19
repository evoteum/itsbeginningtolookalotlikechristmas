## Decision-making process
### Containers or Serverless
The modern standard for most architectural discussions is containerise it and when handling 
containerised workloads, Kubernetes (K8s) is arguably the gold standard for 
enterprise applications. Unfortunately, with enterprise solutions comes enterprise costs, and 
K8s is no exception. Running your own K8s cluster takes a high level of attention while running 
EKS or AKS takes $876 per year - not the dosh that most people are happy to spend on something 
that is unlikely to see even $8.76 per year. It is probably best to avoid using K8s until you 
absolutely have to.

To minimise costs, the "serverless" AWS Lambda approach was considered: the call to Spotify runs 
for a mean runtime of just 0.156 seconds and it does that once per day, so a function-per-invocation 
model would have been cheap to run. More data is often better but when there is no significant 
change between samples, this leads to diminishing returns, so an event-driven trigger was always 
going to be enough. In the end, GitHub Actions was selected instead of Lambda, simply because it 
was the simplest option available: the repo already lived on GitHub, so a scheduled workflow needed 
no extra account, no extra credentials, and no extra infrastructure to provision. It simply appends 
the timestamp and popularity score to `data.csv` in this repo. Clearly, a more robust solution would 
be a proper database, but again this project aims to be as light as possible.

### From GitHub Actions to Kubernetes
For two years, the GitHub Actions workflow happily updated `data.csv` every night without issue. 
Then, in June 2026, an email arrived from GitHub: there had been "no activity on the repository for 
60 days", and the scheduled workflow had been automatically disabled as a result. GitHub Actions, 
for all its simplicity, schedules workflows on a best-effort basis and disables them on repos it 
deems inactive - a `git push` of a single appended line per day apparently doesn't count. By this 
point a bare-metal Kubernetes cluster already existed for other services, which prompted a migration: 
data gathering now runs as a `CronJob` in the 
[kubernetes-lab-services](https://github.com/evoteum/kubernetes-lab-services) cluster, defined in 
the Helm chart at [`chart/`](../chart/). The CronJob's `fetch-popularity` step runs a 
pre-built image of [`python/main.py`](../python/main.py), produced by the standard 
`container-build-and-push` reusable workflow and pushed to `quay.io/evoteum/itsbeginningtolookalotlikechristmas` 
- no `pip install` at run time. Lightweight `git` init/main containers either side of it clone the repo 
and push the updated `data.csv` straight back, so the data remains in git. The same chart also 
deploys an nginx pod serving the static site, with a `git-sync` sidecar keeping `data.csv` 
fresh from this repo; public traffic reaches it via a Cloudflare Tunnel managed by Crossplane 
in [kubernetes-lab-config](https://github.com/evoteum/kubernetes-lab-config). DNS for 
`itsbeginningtolookalotlike.christmas` is also managed by Crossplane. The `tofu/` directory 
has been removed entirely.

In hindsight, picking GitHub Actions for every scheduling problem because it had worked for CI was 
a bit of a golden-hammer move; "simplest option available" and "right tool for an unattended daily 
cron job running indefinitely" are not always the same thing.

### Backend
The modern enterprise would want to build their applications on robust, highly supported web 
frameworks; in Python two popular examples include Django and Flask. As this site simply shows a 
graph and, as such, is not doing anything fancy such as user management, a dynamic backend would 
be overkill, so purely static hosting option is perfectly permissible.

Therefore, the site simply uses [Chart JS](https://youtu.be/HFAjrai-d58) to render the graph 
client side.

## Application maintenance

## Future improvements
The intention is that IBTLALLC will, in the future, listen to many local radio 
stations all the time so that it can identify where and when Christmas begins. Additionally, 
it may be necessary to plan for additional site traffic, which would necessitate the move away 
from cheap-ass static website hosting.

Possible solutions for this include but are not necessarily limited to,
- Container-Serverless Hybrid<br />Data gathering takes place in Lambda and the front end takes 
  place in K8s.
- Containers all the way<br />Everything gets run in K8s to reduce complexity by providing a 
  standard approach. The UI is hosted by long-running containers and the data gathering is 
  executed in scheduled containers.

