**1. Test Django**
```
python manage.py test
```

**2. Build Container**
```
docker build -f <path/to/Dockerfile> \
    -t <registry-url>/<image-name>:latest \
    -t <registry-url>/<image-name>:<tag(commit-id)> \
    .
```

**3. Push Container Image to Registry**
```
docker push <registry-url>/<image-name> --all-tags
```

**4. Update Secrets**
```
kubectl delete secret <deployment-secret-name>
kubectl create secret generic <deployment-secret-name> --from-env-file=<path/to/.env>
```

**5. Update Deployment**
```
kubectl apply -f k8s/app/<deployment-name>.yml
```

**6. Wait for the rollout**
```
kubectl rollout status deployment/<deployment-name>
```

**7. Migrate Database**
```

```