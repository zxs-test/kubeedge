{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cloudcore.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cloudcore.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Generate certificates for kubeedge cloudstream server
*/}}
{{- define "cloudcore.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "cloudcore.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "cloudcore.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "cloudcore-ca" 365 -}}
{{- $cert := genSignedCert ( include "cloudcore.name" . ) nil $altNames 365 $ca -}}
streamCA.crt: {{ $ca.Cert | b64enc }}
stream.crt: {{ $cert.Cert | b64enc }}
stream.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/*
Generate certificates for kubeedge cloudstream server
*/}}
{{- define "admission.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" "kubeedge-admission-service" .Release.Namespace ) ( printf "%s.%s.svc" "kubeedge-admission-service" .Release.Namespace ) -}}
{{- $ca := genCA "admission-ca" 365 -}}
{{- $cert := genSignedCert "kubeedge-admission-service" nil $altNames 365 $ca -}}
streamCA.crt: {{ $ca.Cert | b64enc }}
stream.crt: {{ $cert.Cert | b64enc }}
stream.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{- define "buildCACert" -}}
  {{- $ca := .ca -}}
  {{- $signingCA := .signingCA -}}
  {{- $signed := genSignedCert "tls-ca" nil nil 3650 $signingCA -}}
  {{- $signedTLSCACert := buildCustomCert $signed.Cert $ca.Key -}}
  {{- dict "Cert" $signedTLSCACert -}}
{{- end -}}
