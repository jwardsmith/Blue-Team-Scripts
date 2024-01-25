# PICERL Cheat Sheet

https://www.sans.org/media/score/504-incident-response-cycle.pdf

*The term “incident” refers to actions that result in harm or the significant threat of harm to your computer systems or data.* An “event” is any observable occurrence in a system and/or network.*

### Preparation

*Get the team ready to handle incidents.*

- People - are our people trained, and tested?
- Policy - do we have warning banners that explicitly define our organisation’s policy on the presumption of privacy, do we have an approach to incident handling (contain and clear, or watch and learn), and do we have a policy for outside "peer" notification?
- Management Support - do we have management support for an incident handling capability?
- Building a Team - do we have qualified people on the team?
- Checklists & Team Issues - do we have system build checklists for backing up and rebuilding, and do we have a compensation plan for the team?
- Team Organisation - do we have a solid team structure?
- Emergency Comm Plan - do we have an emergency communications plan, and a call list?
- Access to Systems & Data - do we have controlled access to systems and data?
- Point of Contact & Resources - do we have a primary point of contact,an incident command communications centre, and resource acquisition plans for the team?
- Reporting Facilities - do we have a way user's can report abnormal activity to us (phone hotline, email, intranet website)?
- Train the Team - are our incident responders trained (tools/techniques training)?
- Cultivate Relationships - do we have good relationships with our service desk and system admin/network admin employees?
- Jump Bag - do we have a jump bag stocked with fresh media for storing system images (CDs/USBs/HDDs)?
- Processes - do we have playbooks/SOPs/templates?
- Technology - do we have security tooling e.g. SIEM/EDR/Proxy, do we have binary image-creation software e.g. dd, Netcat, ncat, or Safeback, do we have forensic software e.g. Sleuth Kit, Autopsy, EnCase, Forensics Toolkit (FTK), or X-Ways Forensics, do we have diagnosis software we can trust, and do we have investigative tools e.g. SANS SIFT VM?

### Identification

*The bulk of all detects will come from either sensor platforms or the things people just happen to notice. Can occur at the network perimeter (external-facing NIDS/NIPS), host perimeter (personal FW/HIDS/HIPS), system-level (AV/EDR/FIM), or application-level (web app, cloud service). https://zeltser.com/security-incident-questionnaire-cheat-sheet/.*

- Be willing to alert early!
- Assigning Handlers - do we have a primary incident handler?
- Control the Flow of Information - have we enforced a need to know policy?
- Communication Channels - do we have out-of-band communication channels (use telephone and faxes)?
- Establish Chain of Custody - do we have a provable chain of custody?

### Containment

*Stop the bleeding.*

- Characterise Incident - do we know the category (DoS, compromised asset, malware, phish), criticality (critical, high, medium, low, info), and sensitivity of the incident (extremely sensitive, sensitive, less sensitive).
- Inform Management - have we notified our manager?
- Inform Impacted Business Unit - have we notified the impacted business unit?
- Incident Tracking Entry - have we created a ticket for documentation and tracking purposes?
- Short-Term Containment - isolate device so it cannot connect to corporate VPN, disable AD account, force shut down, disconnect network cable, pull power cable (loses volatile memory, and may damage drive), apply filters to routers or firewalls, change a name in DNS to point to a different IP address (most attackers target systems based on their IP address) (altering DNS so that the domain name for the impacted system points to a different IP address, perhaps one where you have a newly installed, secured machine offering up the desired production service).
- ISP Coordination - do we need to ISP assistance for large packet floods, bot-nets, worms?
- Creating Forensics Images - can we create an image (bit-by-bit image to get all file system data including deleted and fragmentary files) of memory, as well as the filesystem as soon as possible (dd, Memoryze, FTK)?
- Drive Duplicator Hardware and Write Blockers - do we have drive duplicator (copy entire drives with ease) and write-blocking hardware (read-only copies)?
- Determine Risk of Continuing Operations - how far did the attacker get, and do we need a recommendation for longer term containment?
- Long-Term Decision - can the system be kept offline, therefore we can move to the Eradication phase, or does the system have to be kept in production, therefore we need to perform long-term containment?
- Lomg-Term Containment - patch the system, patch neighbouring systems, insert an IPS, null routing, change passwords, alter trust relationships, apply firewall and router filter rules, remove accounts used by the attacker, and shutdown backdoor processes used by the attacker (the idea for long-term containment is to apply a temporary band-aid to stay in production while you are building a clean system during eradication)?
### Eradication

### Recovery

### Lessons Learned
