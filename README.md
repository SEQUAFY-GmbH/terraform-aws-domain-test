# AWS Active Directory Testumgebung

Dieses Terraform Projekt erstellt ein VPC mit einem privaten und einem öffentlichen Subnet inkl. NAT- und Internet-Gateway.

Privates Subnet: 10.0.1.0/24
Öffentliches Subnet: 10.0.2.0/24

Es werden zwei Domaincontroller, sowie ein Demohost erstellt, auf den per RDP zugegriffen werden kann.

Ein non-domainjoined Jumper-Host wird erstellt. Falls auf den Jumper-Host per RDP zugegegriffen werden soll, muss die eigene öffentliche IP in der public_ip Variable als erlaubte IP hinterlegt werden.  Das Passwort für den lokalen Admin ist das gleiche wie für den Domänenadmin. Die Domaincontroller selbst, sowie der Demohost sind nicht öffentlich erreichbar.

## Hinweise

In variables.tf kann der Domainname, sowie das Passwort für das Domainadmin-Konto geändert werden.