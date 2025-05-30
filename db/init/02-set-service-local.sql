-- db/init/02-set-service-local.sql

-- After restoring production blobs, switch them to the local service:
UPDATE active_storage_blobs
  SET service_name = 'local'
  WHERE service_name <> 'local';