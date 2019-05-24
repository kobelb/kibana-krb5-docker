FROM ubuntu:14.04
ENV REALM_NAME TEST.ELASTIC.CO
ADD src /src
RUN echo kerberos.test.elastic.co > /etc/hostname && echo "127.0.0.1 kerberos.test.elastic.co" >> /etc/hosts
RUN bash /src/main/resources/provision/installkdc.sh

RUN kadmin.local -q "addprinc -pw changeme HTTP/es@$REALM_NAME" && \
kadmin.local -q "ktadd -k /root/es.keytab HTTP/es@$REALM_NAME" && \
kadmin.local -q "addprinc -pw changeme dev@$REALM_NAME"

EXPOSE 88
EXPOSE 88/udp

CMD /usr/sbin/krb5kdc -n
