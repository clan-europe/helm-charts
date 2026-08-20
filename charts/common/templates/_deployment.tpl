{{- define "common.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
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
      {{- if and .Values.waitForPocketbase .Values.waitForPocketbase.enabled }}
      {{- $pbHealthUrl := .Values.waitForPocketbase.url | default (printf "%s/api/health" (.Values.config.POCKETBASE_URL | default "")) }}
      initContainers:
        - name: wait-for-pocketbase
          image: {{ .Values.waitForPocketbase.image | default "busybox:latest" }}
          command:
            - sh
            - -c
            - "until wget -q --spider {{ $pbHealthUrl }}; do echo 'waiting for pocketbase'; sleep 2; done"
      {{- end }}
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          {{- with .Values.command }}
          command: {{ toJson . }}
          {{- end }}
          {{- with .Values.service }}
          ports:
            - name: http
              containerPort: {{ .containerPort | default 3000 }}
              protocol: TCP
          {{- end }}
          {{- with .Values.probes }}
          livenessProbe:
            httpGet:
              path: {{ .path | default "/api/" }}
              port: http
            initialDelaySeconds: 15
            periodSeconds: 20
          readinessProbe:
            httpGet:
              path: {{ .path | default "/api/" }}
              port: http
            initialDelaySeconds: 5
            periodSeconds: 10
          {{- end }}
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
          {{- with .Values.volumeMounts }}
          volumeMounts:
            {{- toYaml . | nindent 12 }}
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
      {{- with .Values.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
