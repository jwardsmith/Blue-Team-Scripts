This checklist aims to provide new SOC analysts with a step-by-step guide on the thought process they should use to analyse any type of alert. The steps are not applicable to all alerts, and are not exhaustive.

1. Validate Alert Details:
- Did the user really click the link?
- Did the email really get sent by the sender email address?
- Did the email really get received by the recipient email address?
- Did the file really execute?
- Did the user really enter their credentials on this page?
- Did the device really establish a connection to this IP address?
2. Get Sample:
- Can I get a copy of the file/email from the user's local system using UNC path?
- Can I get a copy of the file/email from the user's local system using EDR?
- Can I get a copy of the file/email from the user's Outlook/Teams/OneDrive/SharePoint using eDiscovery?
- Can I get a copy of the file/email from the user's local system by asking the user?
- Can I view this script in a text editor?
- Can I sandbox this in a public sandbox?
3. Validate Alert (is it malicious or is it legitimate?):
- QUESTION EVERYTHING! DO NOT RELY ON THE TOOLS!
- What does the process tree look like? Parents/Childs?
- Is the name of the file suspicious?
- Is the directory of the file suspicious?
- Where was the file downloaded from?
- Is the hash of the file reported as malicious?
- Is the file digitally signed by a trusted signer?
- Is the hash of the parent process reported as malicious?
- Is the parent process digitally signed by a trusted signer?
- Is the email from a trusted email sender domain?
- Are the links in the email actually malicious?
- Are there any macros in this document?
- Does the IP address/domain have public Whois information?
- Does the IP address/domain have a bad reputation?
- Does the IP address/domain appear on threat intelligence blacklists?
- What are the community saying about this IP address/domain?
- Who are the vendors flagging this IOC as malicious? Are they reputable?
- What volume of vendors are flagging this IOC as malicious? Is is a majority?
- Does the URL lead to a malicious website?
- Does the URL download a file once visited?
- Are there repeated connections to the same IP/domain/URL?
- Is there a login form on this URL?
