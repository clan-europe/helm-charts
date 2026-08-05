{{- define "common.statefulset" -}}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount | default 1 }}
  serviceName: {{ include "common.fullname" . }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        {{- if include "common.hasConfig" . }}
        checksum/config: {{ include "common.configmap" . | sha256sum }}
        {{- end }}
        {{- if include "common.hasSecrets" . }}
        checksum/secret: {{ include "common.secret" . | sha256sum }}
        {{- end }}
        {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      labels:
        {{- include "common.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "common.serviceAccountName" . }}
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          {{- with .Values.command }}
          command: {{ toJson . }}
          {{- end }}
          ports:
            - name: http
              containerPort: {{ .Values.service.containerPort | default 8090 }}
              protocol: TCP
          livenessProbe:
            httpGet:
              path: {{ (.Values.probes).path | default "/api/health" }}
              port: http
            initialDelaySeconds: 15
            periodSeconds: 20
          readinessProbe:
            httpGet:
              path: {{ (.Values.probes).path | default "/api/health" }}
              port: http
            initialDelaySeconds: 5
            periodSeconds: 10
          {{- if or (include "common.hasConfig" .) (include "common.hasSecrets" .) }}
          envFrom:
            {{- if include "common.hasConfig" . }}
            - configMapRef:
                name: {{ include "common.fullname" . }}-config
            {{- end }}
            {{- if include "common.hasSecrets" . }}
            - secretRef:
                name: {{ include "common.secretName" . }}
            {{- end }}
          {{- end }}
          {{- with .Values.extraEnv }}
          env:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- $p := .Values.persistence | default dict }}
          {{- if $p.enabled }}
          volumeMounts:
            - name: data
              mountPath: {{ $p.mountPath | default "/opt/app/pb_data" }}
          {{- end }}
          {{- with .Values.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
  {{- $p := .Values.persistence | default dict }}
  {{- if $p.enabled }}
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes:
          - ReadWriteOnce
        {{- if $p.storageClassName }}
        storageClassName: {{ $p.storageClassName | quote }}
        {{- end }}
        resources:
          requests:
            storage: {{ $p.size | default "8Gi" }}
  {{- end }}
{{- end }}
