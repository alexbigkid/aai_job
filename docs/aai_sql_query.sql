SELECT p.project_name, d.name as device_name, d.created_at
FROM projects p
JOIN project_devices pd on p.id = pd.project_id
JOIN devices d on pd.device_id = d.id
ORDER BY p.project_name
