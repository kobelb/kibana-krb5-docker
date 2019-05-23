FROM ubuntu:14.04
ENV REALM_NAME TEST.ELASTIC.CO
ADD . /fixture
RUN echo kerberos.test.elastic.co > /etc/hostname && echo "127.0.0.1 kerberos.test.elastic.co" >> /etc/hosts
RUN bash /fixture/src/main/resources/provision/installkdc.sh

EXPOSE 88
EXPOSE 88/udp

RUN /bin/bash -c 'kadmin.local -q "addprinc -pw changeme dev@$REALM_NAME"'
RUN /bin/bash -c 'kadmin.local -q "ktadd -k /fixture/dev.keytab dev/dev@$REALM_NAME"'

CMD /usr/sbin/krb5kdc -n
