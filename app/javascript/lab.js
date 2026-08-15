let labController;

const setupSignalGarden = () => {
  const root = document.querySelector('[data-signal-garden]');
  if (!root) return;

  labController?.abort();
  labController = new AbortController();
  const { signal } = labController;
  const canvas = root.querySelector('[data-lab-canvas]');
  const context = canvas.getContext('2d');
  const fpsOutput = root.querySelector('[data-lab-fps]');
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const palettes = {
    violet: ['#f9e71c', '#bcaeff', '#8b6cff'],
    solar: ['#fff2a8', '#ff9f43', '#ff4d7d'],
    ocean: ['#d8ffff', '#42d9c8', '#3b82f6'],
  };
  const settings = { density: 72, flow: 58, trail: 68, palette: 'violet' };
  const pointer = { x: 0, y: 0, active: false };
  let particles = [];
  let width = 0;
  let height = 0;
  let frame = 0;
  let paused = reducedMotion;
  let lastFrameAt = performance.now();
  let fpsSampleAt = lastFrameAt;
  let framesSinceSample = 0;

  const createParticle = (randomAge = true) => ({
    x: Math.random() * width,
    y: Math.random() * height,
    vx: 0,
    vy: 0,
    age: randomAge ? Math.random() * 260 : 0,
    life: 160 + Math.random() * 240,
    color: Math.floor(Math.random() * 3),
  });

  const particleCount = () => Math.round((width * height / 4200) * (settings.density / 60));
  const resetParticles = () => { particles = Array.from({ length: particleCount() }, () => createParticle()); };

  const resize = () => {
    const bounds = canvas.getBoundingClientRect();
    const scale = Math.min(window.devicePixelRatio || 1, 2);
    width = bounds.width;
    height = bounds.height;
    canvas.width = Math.round(width * scale);
    canvas.height = Math.round(height * scale);
    context.setTransform(scale, 0, 0, scale, 0, 0);
    resetParticles();
    context.fillStyle = '#100b25';
    context.fillRect(0, 0, width, height);
    if (reducedMotion) draw(performance.now());
  };

  const fieldAngle = (x, y, time) => {
    const scale = 0.006 + settings.flow * 0.000025;
    return Math.sin(x * scale + time * 0.00018) * 2.2 + Math.cos(y * scale - time * 0.00013) * 1.8;
  };

  const draw = (time) => {
    const fade = 0.04 + (100 - settings.trail) * 0.0026;
    context.fillStyle = `rgba(16, 11, 37, ${fade})`;
    context.fillRect(0, 0, width, height);
    context.lineWidth = 0.7;

    particles.forEach((particle, index) => {
      const previousX = particle.x;
      const previousY = particle.y;
      const angle = fieldAngle(particle.x, particle.y, time);
      const acceleration = 0.035 + settings.flow * 0.00065;
      particle.vx = particle.vx * 0.94 + Math.cos(angle) * acceleration;
      particle.vy = particle.vy * 0.94 + Math.sin(angle) * acceleration;

      if (pointer.active) {
        const dx = particle.x - pointer.x;
        const dy = particle.y - pointer.y;
        const distanceSquared = dx * dx + dy * dy;
        if (distanceSquared < 24000 && distanceSquared > 1) {
          const force = (1 - Math.sqrt(distanceSquared) / 155) * 0.7;
          particle.vx += (dx / Math.sqrt(distanceSquared)) * force;
          particle.vy += (dy / Math.sqrt(distanceSquared)) * force;
        }
      }

      particle.x += particle.vx;
      particle.y += particle.vy;
      particle.age += 1;
      if (particle.age > particle.life || particle.x < -10 || particle.x > width + 10 || particle.y < -10 || particle.y > height + 10) {
        particles[index] = createParticle(false);
        return;
      }

      const alpha = Math.min(particle.age / 30, (particle.life - particle.age) / 35, 0.82);
      context.strokeStyle = `${palettes[settings.palette][particle.color]}${Math.max(0, Math.round(alpha * 255)).toString(16).padStart(2, '0')}`;
      context.beginPath();
      context.moveTo(previousX, previousY);
      context.lineTo(particle.x, particle.y);
      context.stroke();
    });

    framesSinceSample += 1;
    if (time - fpsSampleAt > 750) {
      const fps = Math.round((framesSinceSample * 1000) / (time - fpsSampleAt));
      fpsOutput.textContent = `${Math.min(fps, 60)} FPS`;
      fpsSampleAt = time;
      framesSinceSample = 0;
    }
    lastFrameAt = time;
  };

  const animate = (time) => {
    if (!paused) draw(time);
    frame = requestAnimationFrame(animate);
  };

  const updatePointer = (event) => {
    const bounds = canvas.getBoundingClientRect();
    pointer.x = event.clientX - bounds.left;
    pointer.y = event.clientY - bounds.top;
    pointer.active = true;
  };

  root.querySelectorAll('[data-lab-control]').forEach((control) => {
    control.addEventListener('input', () => {
      const name = control.dataset.labControl;
      settings[name] = Number(control.value);
      root.querySelector(`[data-output="${name}"]`).textContent = control.value;
      if (name === 'density') resetParticles();
      if (reducedMotion) draw(performance.now());
    }, { signal });
  });

  root.querySelectorAll('[data-lab-palette]').forEach((button) => {
    button.addEventListener('click', () => {
      settings.palette = button.dataset.labPalette;
      root.querySelectorAll('[data-lab-palette]').forEach((option) => {
        const selected = option === button;
        option.classList.toggle('is-active', selected);
        option.setAttribute('aria-pressed', selected.toString());
      });
      if (reducedMotion) draw(performance.now());
    }, { signal });
  });

  root.querySelector('[data-lab-action="randomize"]').addEventListener('click', () => {
    resetParticles();
    context.fillStyle = '#100b25';
    context.fillRect(0, 0, width, height);
    if (reducedMotion) draw(performance.now());
  }, { signal });

  const pauseButton = root.querySelector('[data-lab-action="pause"]');
  const updatePauseButton = () => {
    pauseButton.setAttribute('aria-pressed', paused.toString());
    pauseButton.querySelector('i').className = paused ? 'bx bx-play' : 'bx bx-pause';
    pauseButton.querySelector('span').textContent = paused ? 'Play' : 'Pause';
  };
  pauseButton.addEventListener('click', () => { paused = !paused; updatePauseButton(); }, { signal });
  updatePauseButton();

  const localButton = root.querySelector('[data-lab-action="local"]');
  const localReadout = root.querySelector('[data-lab-local]');
  const modeSelect = root.querySelector('[data-lab-mode]');
  let coordinates;
  const applySetting = (name, value) => {
    settings[name] = Math.round(value);
    const control = root.querySelector(`[data-lab-control="${name}"]`);
    control.value = settings[name];
    root.querySelector(`[data-output="${name}"]`).textContent = settings[name];
  };
  const applyLocalSignal = async () => {
    if (!coordinates) return;
    const [latitude, longitude] = coordinates;
    if (modeSelect.value === 'traffic') {
      const hour = new Date().getHours();
      const peak = Math.max(Math.exp(-((hour - 8) ** 2) / 7), Math.exp(-((hour - 17) ** 2) / 9));
      const traffic = Math.round(25 + peak * 70);
      applySetting('density', traffic);
      applySetting('flow', 105 - traffic * 0.65);
      applySetting('trail', 78);
      localReadout.innerHTML = `<span>MODELED LOCAL TRAFFIC · ${latitude.toFixed(2)}, ${longitude.toFixed(2)}</span><strong>${traffic}% congestion signal based on local time</strong>`;
      resetParticles();
      return;
    }
    localReadout.innerHTML = '<span>LIVE WEATHER</span><strong>Reading the atmosphere…</strong>';
    try {
      const response = await fetch(`https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,precipitation,cloud_cover,wind_speed_10m&temperature_unit=fahrenheit`);
      if (!response.ok) throw new Error('Weather unavailable');
      const data = await response.json();
      const weather = data.current;
      applySetting('flow', Math.min(100, 22 + weather.wind_speed_10m * 3));
      applySetting('density', Math.min(100, 42 + weather.cloud_cover * 0.45));
      applySetting('trail', weather.precipitation > 0 ? 88 : 62);
      settings.palette = weather.precipitation > 0 || weather.cloud_cover > 65 ? 'ocean' : 'solar';
      root.querySelectorAll('[data-lab-palette]').forEach((option) => {
        const selected = option.dataset.labPalette === settings.palette;
        option.classList.toggle('is-active', selected);
        option.setAttribute('aria-pressed', selected.toString());
      });
      localReadout.innerHTML = `<span>LIVE WEATHER · ${latitude.toFixed(2)}, ${longitude.toFixed(2)}</span><strong>${Math.round(weather.temperature_2m)}°F · ${Math.round(weather.wind_speed_10m)} mph wind · ${weather.cloud_cover}% cloud</strong>`;
      resetParticles();
    } catch (_error) {
      localReadout.innerHTML = '<span>WEATHER SIGNAL UNAVAILABLE</span><strong>Try again or explore the field manually</strong>';
    }
  };
  localButton.addEventListener('click', () => {
    if (!navigator.geolocation) return;
    localButton.querySelector('span').textContent = 'Locating…';
    navigator.geolocation.getCurrentPosition((position) => {
      coordinates = [position.coords.latitude, position.coords.longitude];
      localButton.querySelector('span').textContent = 'Refresh location';
      applyLocalSignal();
    }, () => {
      localButton.querySelector('span').textContent = 'Location unavailable';
      localReadout.innerHTML = '<span>LOCATION PRIVATE</span><strong>You can continue shaping the demo signal</strong>';
    }, { timeout: 10000 });
  }, { signal });
  modeSelect.addEventListener('change', applyLocalSignal, { signal });

  canvas.addEventListener('pointermove', updatePointer, { signal });
  canvas.addEventListener('pointerdown', updatePointer, { signal });
  canvas.addEventListener('pointerleave', () => { pointer.active = false; }, { signal });
  window.addEventListener('resize', resize, { signal });
  signal.addEventListener('abort', () => cancelAnimationFrame(frame), { once: true });
  resize();
  frame = requestAnimationFrame(animate);
};

const setupRidesSimulation = () => {
  const root = document.querySelector('[data-rides-simulation]');
  if (!root) return;
  const canvas = root.querySelector('[data-rides-canvas]');
  const context = canvas.getContext('2d');
  const tileLayer = root.querySelector('[data-rides-tiles]');
  const servicePanel = document.querySelector('[data-service-load]');
  const serviceProfiles = {
    users: { multiplier: 4.2, latency: 42, color: '#9d86ff' }, pricing: { multiplier: 7.8, latency: 68, color: '#f9e71c' },
    rides: { multiplier: 11.5, latency: 84, color: '#ff8c42' }, dispatch: { multiplier: 14.2, latency: 112, color: '#ff3f9b' },
    location: { multiplier: 24.5, latency: 38, color: '#42d9c8' }, payments: { multiplier: 2.8, latency: 146, color: '#6ca8ff' },
    notifications: { multiplier: 3.7, latency: 55, color: '#c89cff' }, reviews: { multiplier: 0.7, latency: 73, color: '#ffbd66' },
    resources: { multiplier: 1.4, latency: 91, color: '#8ad6a3' },
  };
  const serviceHistories = Object.fromEntries(Object.keys(serviceProfiles).map((name) => [name, Array(60).fill(0)]));
  const overloadProfiles = { rides: 2.0, dispatch: 3.8, payments: 2.4 };
  let lastServiceSample = 0;
  const controls = { load: 65, supply: 72, cancel: 8 };
  const standardRouteDefinitions = [
    [[-122.4324, 37.7692], [-122.4262, 37.7767], [-122.4087, 37.7878]],
    [[-122.4145, 37.7846], [-122.4208, 37.7794], [-122.4472, 37.7684]],
    [[-122.4501, 37.7811], [-122.4392, 37.7743], [-122.4161, 37.7668]],
    [[-122.4017, 37.7891], [-122.4078, 37.7818], [-122.4275, 37.7617]],
    [[-122.4213, 37.7582], [-122.4148, 37.7649], [-122.4042, 37.7785]],
    [[-122.4466, 37.7598], [-122.4347, 37.7631], [-122.4183, 37.7871]],
    [[-122.4074, 37.7712], [-122.4167, 37.7725], [-122.4396, 37.7890]],
    [[-122.4334, 37.7910], [-122.4254, 37.7850], [-122.3977, 37.7780]],
  ];
  const hotspotCenters = { concert: [-122.3878, 37.7680] };
  const hotspotPickups = {
    concert: [[-122.3878, 37.7680], [-122.3884, 37.7686], [-122.3871, 37.7675]],
  };
  let selectedScenario = 'steady';
  let trips = [];
  const routeCaches = {};
  let startTime = 0;
  let animation;
  let completedRides = 0;
  let width;
  let height;
  let mapCenterX;
  let mapCenterY;
  const zoom = 13;
  const worldSize = 256 * (2 ** zoom);
  const phases = [{ name: 'Ramp', end: 12 }, { name: 'Soak', end: 30 }, { name: 'Recovery', end: 42 }];

  const worldPoint = ([longitude, latitude]) => {
    const radians = latitude * Math.PI / 180;
    return [((longitude + 180) / 360) * worldSize, (1 - Math.log(Math.tan(radians) + 1 / Math.cos(radians)) / Math.PI) / 2 * worldSize];
  };
  const screenPoint = (coordinate) => { const [x, y] = worldPoint(coordinate); return [x - mapCenterX + width / 2, y - mapCenterY + height / 2]; };

  const renderSanFranciscoMap = () => {
    const tileSize = 256; const scale = 2 ** zoom;
    const longitude = -122.4194; const latitude = 37.7749;
    const centerX = ((longitude + 180) / 360) * scale;
    const radians = latitude * Math.PI / 180;
    const centerY = (1 - Math.log(Math.tan(radians) + 1 / Math.cos(radians)) / Math.PI) / 2 * scale;
    const tilesAcross = Math.ceil(width / tileSize) + 2; const tilesDown = Math.ceil(height / tileSize) + 2;
    const startX = Math.floor(centerX - tilesAcross / 2); const startY = Math.floor(centerY - tilesDown / 2);
    const offsetX = width / 2 - (centerX - startX) * tileSize; const offsetY = height / 2 - (centerY - startY) * tileSize;
    [mapCenterX, mapCenterY] = worldPoint([longitude, latitude]); tileLayer.replaceChildren();
    for (let y = 0; y < tilesDown; y += 1) for (let x = 0; x < tilesAcross; x += 1) {
      const image = document.createElement('img'); image.alt = ''; image.decoding = 'async'; image.src = `https://a.basemaps.cartocdn.com/light_all/${zoom}/${startX + x}/${startY + y}@2x.png`; image.style.left = `${offsetX + x * tileSize}px`; image.style.top = `${offsetY + y * tileSize}px`; tileLayer.appendChild(image);
    }
  };

  const resize = () => {
    const bounds = canvas.getBoundingClientRect();
    const ratio = Math.min(devicePixelRatio || 1, 2);
    width = bounds.width; height = bounds.height;
    canvas.width = width * ratio; canvas.height = height * ratio;
    context.setTransform(ratio, 0, 0, ratio, 0, 0); renderSanFranciscoMap();
  };
  const definitionsForScenario = () => {
    if (selectedScenario === 'steady' || selectedScenario === 'overload') return standardRouteDefinitions;
    return standardRouteDefinitions.map(([driver, _rider, dropoff], index) => [driver, hotspotPickups[selectedScenario][index % 3], dropoff]);
  };
  const loadRoutes = () => {
    if (routeCaches[selectedScenario]) return routeCaches[selectedScenario];
    const routeDefinitions = definitionsForScenario();
    routeCaches[selectedScenario] = Promise.all(routeDefinitions.map(async (definition) => {
      const coordinates = definition.map((point) => point.join(',')).join(';');
      const response = await fetch(`https://router.project-osrm.org/route/v1/driving/${coordinates}?steps=true&overview=false&geometries=geojson`);
      if (!response.ok) throw new Error('Street routing unavailable');
      const data = await response.json();
      if (data.code !== 'Ok') throw new Error('No street route found');
      const pickupRoute = data.routes[0].legs[0].steps.flatMap((step) => step.geometry.coordinates);
      const dropoffRoute = data.routes[0].legs[1].steps.flatMap((step) => step.geometry.coordinates);
      return { route: [...pickupRoute, ...dropoffRoute.slice(1)], pickupIndex: pickupRoute.length - 1, rider: definition[1] };
    }));
    return routeCaches[selectedScenario];
  };
  const configureTrips = (routes, factor) => {
    const driverCount = Math.max(1, Math.round((80 + controls.load * factor) * Math.max(0.75, controls.supply / 100)));
    trips = Array.from({ length: driverCount }, (_value, index) => {
      const source = routes[index % routes.length];
      const routeIndex = (Math.floor(index / routes.length) * 13 + index * 3) % Math.max(1, source.pickupIndex - 1);
      return { ...source, hasDriver: true, routeIndex, progress: (index % 7) / 7, pickedUp: false, complete: false, speed: 0.58 + Math.random() * 0.5, riderOffset: (index % 9) - 4 };
    });
  };
  const drawRider = (trip) => {
    const [baseX, baseY] = screenPoint(trip.rider); const x = baseX + trip.riderOffset * 1.4; const y = baseY + (trip.riderOffset % 3) * 2; context.fillStyle = '#2388ff'; context.strokeStyle = 'white'; context.lineWidth = 1.2;
    context.beginPath(); context.arc(x, y - 3.2, 2.4, 0, Math.PI * 2); context.fill(); context.stroke();
    context.beginPath(); context.roundRect(x - 2.6, y - 0.7, 5.2, 6.2, 2); context.fill(); context.stroke();
  };
  const drawVehicle = (trip) => {
    const current = screenPoint(trip.route[trip.routeIndex]); const next = screenPoint(trip.route[Math.min(trip.routeIndex + 1, trip.route.length - 1)]);
    const dx = next[0] - current[0]; const dy = next[1] - current[1]; const distance = Math.max(0.1, Math.hypot(dx, dy));
    trip.progress += trip.speed / distance;
    if (trip.progress >= 1) { trip.routeIndex += 1; trip.progress = 0; if (trip.routeIndex >= trip.pickupIndex) trip.pickedUp = true; if (trip.routeIndex >= trip.route.length - 1) { completedRides += 1; trip.routeIndex = 0; trip.progress = 0; trip.pickedUp = false; } }
    const x = current[0] + dx * trip.progress; const y = current[1] + dy * trip.progress; const angle = Math.atan2(dy, dx);
    if (!trip.pickedUp) { context.strokeStyle = 'rgba(35,136,255,.32)'; context.lineWidth = 1; context.beginPath(); context.moveTo(x, y); const rider = screenPoint(trip.rider); context.lineTo(rider[0], rider[1]); context.stroke(); }
    context.save(); context.translate(x, y); context.rotate(angle); context.fillStyle = '#ff3f9b'; context.strokeStyle = 'white'; context.lineWidth = 1.1;
    context.beginPath(); context.roundRect(-6, -3.4, 12, 6.8, 2.4); context.fill(); context.stroke(); context.fillStyle = '#351638'; context.fillRect(-2.4, -2.1, 4.4, 4.2); context.fillStyle = '#f9e71c'; context.fillRect(4.7, -2.1, 1.3, 1.2); context.fillRect(4.7, 1, 1.3, 1.2); context.restore();
  };
  const drawMap = (elapsed = 0, visibleTrips = trips) => {
    context.clearRect(0, 0, width, height);
    if (hotspotCenters[selectedScenario]) {
      const [x, y] = screenPoint(hotspotCenters[selectedScenario]); const pulse = 22 + Math.sin(elapsed * 3) * 4;
      context.fillStyle = 'rgba(35,136,255,.10)'; context.strokeStyle = 'rgba(35,136,255,.65)'; context.lineWidth = 1.2;
      context.beginPath(); context.arc(x, y, pulse, 0, Math.PI * 2); context.fill(); context.stroke();
      context.fillStyle = 'rgba(18,13,41,.82)'; context.beginPath(); context.roundRect(x - 40, y - 37, 80, 17, 8); context.fill();
      context.fillStyle = 'white'; context.font = '600 8px Raleway, sans-serif'; context.textAlign = 'center'; context.fillText('CONCERT EGRESS', x, y - 26);
    }
    visibleTrips.forEach((trip) => { if (!trip.pickedUp) drawRider(trip); if (trip.hasDriver) drawVehicle(trip); });
    const seconds = Math.floor(elapsed);
    root.querySelector('[data-rides-clock]').textContent = `${String(Math.floor(seconds / 60)).padStart(2, '0')}:${String(seconds % 60).padStart(2, '0')}`;
  };
  const updateServiceLoad = (time, loadFactor) => {
    if (!servicePanel || time - lastServiceSample < 250) return;
    lastServiceSample = time; let total = 0;
    servicePanel.querySelectorAll('[data-service-key]').forEach((row) => {
      const name = row.dataset.serviceKey; const profile = serviceProfiles[name];
      if (!profile) return;
      const jitter = 0.94 + Math.random() * 0.12; const overload = selectedScenario === 'overload' ? Math.max(0, (loadFactor - 0.42) / 0.58) : 0; const serviceOverload = overloadProfiles[name] || 0;
      const rps = Math.round(controls.load * profile.multiplier * loadFactor * jitter * (1 + overload * serviceOverload * 0.16)); total += rps;
      const pressure = Math.max(0, loadFactor * controls.load / 100 - 0.82); const latency = Math.round(profile.latency * (1 + pressure * pressure * 4.5 + overload * serviceOverload) * jitter);
      const history = serviceHistories[name]; history.push(rps); history.shift();
      row.querySelector('[data-service-rps]').textContent = rps.toLocaleString(); row.querySelector('[data-service-latency]').textContent = `${latency}ms`;
      const health = row.querySelector('[data-service-health]'); const latencyRatio = latency / profile.latency; const critical = latencyRatio > 3.2; const degraded = latencyRatio > 1.7;
      health.textContent = critical ? 'Critical' : degraded ? 'Degraded' : 'Nominal'; health.classList.toggle('is-degraded', degraded && !critical); health.classList.toggle('is-critical', critical);
      const chart = row.querySelector('canvas'); const bounds = chart.getBoundingClientRect(); const ratio = Math.min(devicePixelRatio || 1, 2);
      if (chart.width !== Math.round(bounds.width * ratio)) { chart.width = Math.round(bounds.width * ratio); chart.height = Math.round(bounds.height * ratio); }
      const chartContext = chart.getContext('2d'); chartContext.setTransform(ratio, 0, 0, ratio, 0, 0); chartContext.clearRect(0, 0, bounds.width, bounds.height);
      chartContext.fillStyle = `${profile.color}18`; chartContext.strokeStyle = profile.color; chartContext.lineWidth = 1.4; chartContext.beginPath();
      const ceiling = Math.max(1, controls.load * profile.multiplier); history.forEach((value, index) => { const x = index / (history.length - 1) * bounds.width; const y = bounds.height - Math.min(1, value / ceiling) * (bounds.height - 3) - 1.5; if (index === 0) chartContext.moveTo(x, y); else chartContext.lineTo(x, y); });
      chartContext.lineTo(bounds.width, bounds.height); chartContext.lineTo(0, bounds.height); chartContext.closePath(); chartContext.fill(); chartContext.beginPath(); history.forEach((value, index) => { const x = index / (history.length - 1) * bounds.width; const y = bounds.height - Math.min(1, value / ceiling) * (bounds.height - 3) - 1.5; if (index === 0) chartContext.moveTo(x, y); else chartContext.lineTo(x, y); }); chartContext.stroke();
    });
    servicePanel.querySelector('[data-service-total]').textContent = `${total.toLocaleString()} RPS`;
  };
  const tick = (time) => {
    const elapsed = (time - startTime) / 1000;
    const phase = phases.find((item) => elapsed < item.end);
    if (!phase) { root.querySelector('[data-rides-phase]').textContent = 'Complete'; root.querySelector('[data-rides-status]').classList.remove('is-running'); root.querySelector('[data-rides-run] span').textContent = 'Run again'; return; }
    const factor = phase.name === 'Ramp' ? Math.max(0.12, elapsed / 12) : phase.name === 'Recovery' ? Math.max(0.08, (42 - elapsed) / 12) : 1;
    const visibleTrips = trips.slice(0, Math.max(1, Math.round(trips.length * factor)));
    const activeRiders = visibleTrips.filter((trip) => !trip.pickedUp).length; const activeDrivers = visibleTrips.filter((trip) => trip.hasDriver).length; const activeTrips = visibleTrips.filter((trip) => trip.pickedUp).length;
    drawMap(elapsed, visibleTrips);
    try { updateServiceLoad(time, factor); } catch (error) { console.warn('Service telemetry update failed', error); }
    root.querySelector('[data-rides-fleet]').textContent = activeDrivers;
    root.querySelector('[data-rides-phase]').textContent = phase.name;
    root.querySelector('[data-rides-metric="requests"]').textContent = Math.round((activeRiders + activeTrips) * 84 * factor);
    root.querySelector('[data-rides-metric="trips"]').textContent = activeTrips;
    root.querySelector('[data-rides-metric="latency"]').textContent = `${(1.1 + Math.max(0, activeRiders - activeDrivers) * 0.7).toFixed(1)}s`;
    root.querySelector('[data-rides-metric="success"]').textContent = `${Math.max(82, Math.round(100 - controls.cancel - Math.max(0, activeRiders - activeDrivers) * 2))}%`;
    animation = requestAnimationFrame(tick);
  };
  root.querySelectorAll('[data-rides-control]').forEach((control) => control.addEventListener('input', () => { controls[control.dataset.ridesControl] = Number(control.value); root.querySelector(`[data-rides-output="${control.dataset.ridesControl}"]`).textContent = `${control.value}%`; }));
  root.querySelectorAll('[data-rides-preset]').forEach((button) => button.addEventListener('click', () => {
    const values = { steady: [45, 80, 4], concert: [85, 62, 12], overload: [100, 75, 28] }[button.dataset.ridesPreset];
    selectedScenario = button.dataset.ridesPreset;
    servicePanel?.classList.toggle('is-overload', selectedScenario === 'overload');
    root.querySelectorAll('[data-rides-preset]').forEach((option) => { const selected = option === button; option.classList.toggle('is-active', selected); option.setAttribute('aria-pressed', selected.toString()); });
    ['load', 'supply', 'cancel'].forEach((name, index) => { controls[name] = values[index]; const input = root.querySelector(`[data-rides-control="${name}"]`); input.value = values[index]; root.querySelector(`[data-rides-output="${name}"]`).textContent = `${values[index]}%`; });
  }));
  root.querySelector('[data-rides-run]').addEventListener('click', async () => { cancelAnimationFrame(animation); const label = root.querySelector('[data-rides-run] span'); label.textContent = 'Routing fleet…'; root.querySelector('[data-rides-phase]').textContent = 'Routing'; const scenario = selectedScenario; try { const routes = await loadRoutes(); completedRides = 0; configureTrips(routes, 1); startTime = performance.now(); root.querySelector('[data-rides-status]').classList.add('is-running'); label.textContent = 'Restart test'; animation = requestAnimationFrame(tick); } catch (_error) { routeCaches[scenario] = null; root.querySelector('[data-rides-phase]').textContent = 'Route unavailable'; label.textContent = 'Try routing again'; } });
  window.addEventListener('resize', resize); resize(); drawMap();
};

const parsePhotoManifest = (root) => { try { return JSON.parse(root.dataset.photos || '[]'); } catch (_error) { return []; } };
const photoHash = (value) => [...value].reduce((hash, character) => ((hash * 33) ^ character.charCodeAt(0)) >>> 0, 5381);
const fallbackPhotoFeatures = (photo) => { const hash = photoHash(photo.url || 'photo'); return { red: 55 + hash % 180, green: 55 + (hash >> 8) % 180, blue: 55 + (hash >> 16) % 180, luminance: 25 + hash % 65, contrast: 25 + (hash >> 7) % 70, saliencyX: 25 + hash % 50, saliencyY: 25 + (hash >> 9) % 50, aspect: Number(photo.width || 1) / Number(photo.height || 1) }; };
const analyzePhoto = (photo) => new Promise((resolve) => {
  const fallback = fallbackPhotoFeatures(photo); const image = new Image(); image.crossOrigin = 'anonymous';
  image.onerror = () => resolve(fallback);
  image.onload = () => {
    try {
      const canvas = document.createElement('canvas'); canvas.width = 32; canvas.height = 32; const context = canvas.getContext('2d', { willReadFrequently: true }); context.drawImage(image, 0, 0, 32, 32); const pixels = context.getImageData(0, 0, 32, 32).data;
      let red = 0; let green = 0; let blue = 0; let luminance = 0; let contrast = 0; let weight = 0; let weightedX = 0; let weightedY = 0;
      for (let y = 0; y < 32; y += 1) for (let x = 0; x < 32; x += 1) { const index = (y * 32 + x) * 4; const r = pixels[index]; const g = pixels[index + 1]; const b = pixels[index + 2]; const light = r * .2126 + g * .7152 + b * .0722; red += r; green += g; blue += b; luminance += light; if (x > 0) { const previous = pixels[index - 4] * .2126 + pixels[index - 3] * .7152 + pixels[index - 2] * .0722; const edge = Math.abs(light - previous); contrast += edge; weight += edge; weightedX += x * edge; weightedY += y * edge; } }
      resolve({ red: red / 1024, green: green / 1024, blue: blue / 1024, luminance: luminance / 1024 / 2.55, contrast: Math.min(100, contrast / 1024), saliencyX: weight ? weightedX / weight / 31 * 100 : 50, saliencyY: weight ? weightedY / weight / 31 * 100 : 50, aspect: image.width / image.height });
    } catch (_error) { resolve(fallback); }
  };
  image.src = photo.url;
});

const setupPhotoConstellation = () => {
  const root = document.querySelector('[data-photo-constellation]'); if (!root) return; const photos = parsePhotoManifest(root); if (!photos.length) return;
  const canvas = root.querySelector('[data-constellation-canvas]'); const context = canvas.getContext('2d'); const preview = root.querySelector('[data-constellation-preview]');
  let width; let height; let axis = 'similarity'; let scale = 1; let offsetX = 0; let offsetY = 0; let dragging = false; let previousPointer; let startPointer; let nodes = photos.map((photo) => ({ photo, features: fallbackPhotoFeatures(photo), image: null, x: 0, y: 0 }));
  const positionNodes = () => nodes.forEach((node, index) => { const f = node.features; if (axis === 'color') { node.x = (f.red - f.blue + 255) / 510; node.y = f.green / 255; } else if (axis === 'light') { node.x = f.luminance / 100; node.y = f.contrast / 100; } else if (axis === 'shape') { node.x = Math.min(1, f.aspect / 2); node.y = (index % 7) / 7; } else { node.x = (f.red * .45 + f.green * .15 + f.aspect * 70) % 255 / 255; node.y = (f.blue * .4 + f.luminance * 1.5 + f.contrast) % 180 / 180; } });
  const resize = () => { const bounds = canvas.getBoundingClientRect(); const ratio = Math.min(devicePixelRatio || 1, 2); width = bounds.width; height = bounds.height; canvas.width = width * ratio; canvas.height = height * ratio; context.setTransform(ratio, 0, 0, ratio, 0, 0); draw(); };
  const screen = (node) => [((node.x - .5) * width * .82 + width / 2 + offsetX) * scale - width * (scale - 1) / 2, ((node.y - .5) * height * .78 + height / 2 + offsetY) * scale - height * (scale - 1) / 2];
  const draw = () => { context.fillStyle = '#100b25'; context.fillRect(0, 0, width, height); context.strokeStyle = 'rgba(153,140,207,.12)'; nodes.forEach((node, index) => { const [x, y] = screen(node); const neighbor = nodes[(index + 1) % nodes.length]; const [nx, ny] = screen(neighbor); context.beginPath(); context.moveTo(x, y); context.lineTo(nx, ny); context.stroke(); }); nodes.forEach((node) => { const [x, y] = screen(node); context.save(); context.beginPath(); context.arc(x, y, 13, 0, Math.PI * 2); context.clip(); if (node.image?.complete) context.drawImage(node.image, x - 18, y - 14, 36, 28); else { const f = node.features; context.fillStyle = `rgb(${f.red} ${f.green} ${f.blue})`; context.fillRect(x - 14, y - 14, 28, 28); } context.restore(); context.strokeStyle = 'rgba(255,255,255,.72)'; context.beginPath(); context.arc(x, y, 13, 0, Math.PI * 2); context.stroke(); }); };
  const selectAt = (clientX, clientY) => { const bounds = canvas.getBoundingClientRect(); const point = [clientX - bounds.left, clientY - bounds.top]; const nearest = nodes.map((node) => ({ node, distance: Math.hypot(screen(node)[0] - point[0], screen(node)[1] - point[1]) })).sort((a, b) => a.distance - b.distance)[0]; if (!nearest || nearest.distance > 30) return; const photo = nearest.node.photo; preview.classList.add('is-visible'); preview.querySelector('img').src = photo.url; preview.querySelector('strong').textContent = photo.title || 'Untitled frame'; preview.querySelector('p').textContent = photo.description || 'A neighboring moment in the archive.'; };
  Promise.all(nodes.map(async (node) => { node.features = await analyzePhoto(node.photo); const image = new Image(); image.onload = draw; image.src = node.photo.url; node.image = image; })).then(() => { positionNodes(); root.querySelector('[data-constellation-status]').textContent = `${nodes.length} frames mapped`; draw(); });
  root.querySelectorAll('[data-constellation-axis]').forEach((button) => button.addEventListener('click', () => { axis = button.dataset.constellationAxis; root.querySelectorAll('[data-constellation-axis]').forEach((item) => item.classList.toggle('is-active', item === button)); positionNodes(); draw(); }));
  canvas.addEventListener('pointerdown', (event) => { dragging = true; startPointer = [event.clientX, event.clientY]; previousPointer = startPointer; canvas.setPointerCapture(event.pointerId); }); canvas.addEventListener('pointermove', (event) => { if (!dragging) return; offsetX += (event.clientX - previousPointer[0]) / scale; offsetY += (event.clientY - previousPointer[1]) / scale; previousPointer = [event.clientX, event.clientY]; draw(); }); canvas.addEventListener('pointerup', (event) => { if (Math.hypot(event.clientX - startPointer[0], event.clientY - startPointer[1]) < 4) selectAt(event.clientX, event.clientY); dragging = false; }); canvas.addEventListener('wheel', (event) => { event.preventDefault(); scale = Math.max(.7, Math.min(2.6, scale + (event.deltaY < 0 ? .12 : -.12))); draw(); }, { passive: false }); window.addEventListener('resize', resize); positionNodes(); resize();
};

const setupPhotographersEye = () => {
  const root = document.querySelector('[data-photographers-eye]'); if (!root) return; const photos = parsePhotoManifest(root); if (!photos.length) return; const image = root.querySelector('[data-eye-image]'); let selected = 0; let mode = 'attention';
  const render = async () => { const photo = photos[selected]; image.src = photo.url; root.querySelector('[data-eye-status]').textContent = 'Analyzing frame…'; const features = await analyzePhoto(photo); root.querySelectorAll('[data-eye-saliency] circle').forEach((circle) => { circle.setAttribute('cx', features.saliencyX); circle.setAttribute('cy', features.saliencyY); }); root.dataset.eyeMode = mode; root.querySelector('[data-eye-luminance]').textContent = `${Math.round(features.luminance)}%`; root.querySelector('[data-eye-contrast]').textContent = `${Math.round(features.contrast)}%`; root.querySelector('[data-eye-orientation]').textContent = features.aspect > 1.15 ? 'Landscape' : features.aspect < .85 ? 'Portrait' : 'Square'; root.querySelector('[data-eye-reading]').textContent = features.contrast > 55 ? 'High-energy visual structure' : features.luminance < 38 ? 'Low-key visual hierarchy' : 'Balanced visual hierarchy'; root.querySelector('[data-eye-copy]').textContent = `The strongest local contrast converges near ${Math.round(features.saliencyX)}% × ${Math.round(features.saliencyY)}% of the frame.`; root.querySelector('[data-eye-status]').textContent = 'Analysis complete'; };
  root.querySelectorAll('[data-eye-select]').forEach((button) => button.addEventListener('click', () => { selected = Number(button.dataset.eyeSelect); root.querySelectorAll('[data-eye-select]').forEach((item) => item.classList.toggle('is-active', item === button)); render(); })); root.querySelectorAll('[data-eye-mode]').forEach((button) => button.addEventListener('click', () => { mode = button.dataset.eyeMode; root.querySelectorAll('[data-eye-mode]').forEach((item) => item.classList.toggle('is-active', item === button)); root.dataset.eyeMode = mode; })); render();
};

const setupPhotoTimeline = () => {
  const root = document.querySelector('[data-photo-timeline]'); if (!root) return; const photos = parsePhotoManifest(root).sort((a, b) => Number(a.timestamp || 0) - Number(b.timestamp || 0)); if (!photos.length) return; const track = root.querySelector('[data-timeline-track]'); const scrubber = root.querySelector('[data-timeline-scrubber]'); let selected = 0;
  photos.forEach((photo, index) => { const figure = document.createElement('button'); figure.type = 'button'; figure.dataset.timelineIndex = index; figure.innerHTML = `<span>${String(index + 1).padStart(2, '0')}</span><img src="${photo.url}" alt="${photo.title || ''}" loading="lazy">`; figure.addEventListener('click', () => update(index)); track.appendChild(figure); });
  const update = (index) => { selected = Math.max(0, Math.min(photos.length - 1, index)); scrubber.value = selected; track.style.transform = `translateX(${-selected * 13.5 - 6}rem)`; track.querySelectorAll('button').forEach((item, itemIndex) => item.classList.toggle('is-active', itemIndex === selected)); const photo = photos[selected]; const date = photo.timestamp ? new Date(Number(photo.timestamp) * 1000) : null; root.querySelector('[data-timeline-year]').textContent = date && !Number.isNaN(date.valueOf()) ? date.getFullYear() : 'Archive'; root.querySelector('[data-timeline-title]').textContent = photo.title || photo.description || 'Untitled frame'; root.querySelector('[data-timeline-position]').textContent = `${String(selected + 1).padStart(2, '0')} / ${String(photos.length).padStart(2, '0')}`; };
  scrubber.addEventListener('input', () => update(Number(scrubber.value))); root.querySelector('[data-timeline-action="previous"]').addEventListener('click', () => update(selected - 1)); root.querySelector('[data-timeline-action="next"]').addEventListener('click', () => update(selected + 1)); root.querySelector('.time-machine-viewport').addEventListener('wheel', (event) => { event.preventDefault(); update(selected + (event.deltaY > 0 || event.deltaX > 0 ? 1 : -1)); }, { passive: false }); update(0);
};

const setupSiteControlRoom = () => {
  const root = document.querySelector('[data-control-room]'); if (!root) return;
  let status; try { status = JSON.parse(root.dataset.status || '{}'); } catch (_error) { status = {}; }
  const startedAt = Date.now(); let refreshedAt = Date.now(); const repository = 'Lordnibbler/railsblog';
  const escapeHtml = (value) => String(value).replace(/[&<>'"]/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' })[character]);
  const clock = root.querySelector('[data-control-clock]'); const refreshAge = root.querySelector('[data-control-refresh]');
  const updateClock = () => { const elapsed = Math.floor((Date.now() - startedAt) / 1000); clock.textContent = `${String(Math.floor(elapsed / 3600)).padStart(2, '0')}:${String(Math.floor(elapsed % 3600 / 60)).padStart(2, '0')}:${String(elapsed % 60).padStart(2, '0')}`; const age = Math.floor((Date.now() - refreshedAt) / 1000); refreshAge.textContent = age < 5 ? 'now' : `${age}s ago`; };
  setInterval(updateClock, 1000); updateClock();

  const formatBytes = (bytes) => { if (!bytes) return '0 KB'; const units = ['B', 'KB', 'MB', 'GB']; const index = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1); return `${(bytes / 1024 ** index).toFixed(index > 1 ? 1 : 0)} ${units[index]}`; };
  const refreshBrowserPerformance = () => {
    const navigation = performance.getEntriesByType('navigation')[0]; const resources = performance.getEntriesByType('resource');
    if (navigation) {
      const complete = navigation.loadEventEnd || performance.now(); const ttfb = navigation.responseStart - navigation.requestStart;
      root.querySelector('[data-perf-navigation]').textContent = `${Math.round(complete - navigation.startTime)} ms`;
      root.querySelector('[data-perf-dom]').textContent = `DOM ready ${Math.round(navigation.domContentLoadedEventEnd - navigation.startTime)} ms`;
      root.querySelector('[data-perf-server]').textContent = `${Math.round(ttfb)} ms TTFB`;
    }
    const transferred = resources.reduce((sum, entry) => sum + (entry.transferSize || 0), navigation?.transferSize || 0);
    root.querySelector('[data-perf-transfer]').textContent = formatBytes(transferred);
    root.querySelector('[data-perf-resources]').textContent = `${resources.length} resources observed by this browser`;
    root.querySelector('[data-new-relic-browser]').textContent = window.newrelic ? 'Browser agent active on this page' : 'Browser agent not detected on this page';
  };

  const refreshProviderTelemetry = async () => {
    const circleState = root.querySelector('[data-circleci-state]'); const circleSummary = root.querySelector('[data-circleci-summary]'); const circleRuns = root.querySelector('[data-circleci-runs]'); const newRelicState = root.querySelector('[data-new-relic-state]');
    try {
      const response = await fetch('/api/v1/operations'); if (!response.ok) throw new Error(`Telemetry returned ${response.status}`); const telemetry = await response.json();
      if (telemetry.circleci?.connected) {
        const runs = telemetry.circleci.runs || []; const durations = runs.map((run) => Number(run.duration)).filter(Number.isFinite); const average = durations.length ? durations.reduce((sum, duration) => sum + duration, 0) / durations.length : 0; const maximum = Math.max(...durations, 1);
        circleState.textContent = durations.length ? `${Math.round(average)} sec average` : 'Connected · no recent runs'; circleSummary.textContent = `${runs.length} recent workflow runs`;
        circleRuns.replaceChildren(...runs.slice().reverse().map((run) => { const bar = document.createElement('i'); bar.style.height = `${Math.max(8, Number(run.duration || 0) / maximum * 100)}%`; bar.className = `is-${run.status || 'unknown'}`; bar.title = `${run.status || 'unknown'} · ${Math.round(run.duration || 0)} sec`; return bar; }));
      } else { circleState.textContent = telemetry.circleci?.state === 'unavailable' ? 'Temporarily unavailable' : 'Token not configured'; circleSummary.textContent = telemetry.circleci?.reason || 'Server-side integration disconnected'; circleRuns.replaceChildren(); }
      if (telemetry.new_relic?.connected) {
        const metrics = telemetry.new_relic.metrics || {}; newRelicState.textContent = `${Math.round(metrics.response_ms || 0)} ms average`;
        root.querySelector('[data-new-relic-browser]').textContent = `P95 ${Math.round(metrics.p95_ms || 0)} ms · ${Number(metrics.rpm || 0).toFixed(1)} rpm · ${Number(metrics.error_rate || 0).toFixed(2)}% errors`;
      } else if (!status.integrations?.new_relic) { newRelicState.textContent = 'Not configured'; }
    } catch (_error) { circleState.textContent = 'Telemetry unavailable'; circleSummary.textContent = 'The site remains operational; provider history could not be loaded.'; }
  };

  const githubRequest = async (path) => { const response = await fetch(`https://api.github.com/repos/${repository}${path}`, { headers: { Accept: 'application/vnd.github+json' } }); if (!response.ok) throw new Error(`GitHub returned ${response.status}`); return response.json(); };
  const refreshGithub = async () => {
    const feed = root.querySelector('[data-github-feed]'); const deployments = root.querySelector('[data-deploy-feed]');
    try {
      const commits = await githubRequest('/commits?per_page=5');
      feed.replaceChildren(...commits.map((commit) => { const item = document.createElement('a'); item.href = commit.html_url; item.target = '_blank'; item.rel = 'noopener'; item.innerHTML = `<i class="bx bx-git-commit"></i><div><strong>${escapeHtml(commit.commit.message.split('\n')[0])}</strong><span>${escapeHtml(commit.sha.slice(0, 7))} · ${escapeHtml(new Date(commit.commit.author.date).toLocaleDateString())}</span></div>`; return item; }));
      const combined = await githubRequest(`/commits/${commits[0].sha}/status`); const buildState = document.createElement('div'); buildState.className = `build-state build-state-${combined.state}`; buildState.innerHTML = `<i></i><span>Latest commit status</span><strong>${combined.state}</strong>`; feed.prepend(buildState);
    } catch (error) { feed.innerHTML = `<div class="control-unavailable"><i class="bx bx-cloud-off"></i><span>Public GitHub activity unavailable</span><small>${escapeHtml(error.message)}</small></div>`; }
    try {
      const records = await githubRequest('/deployments?per_page=4');
      if (!records.length) { deployments.innerHTML = '<div class="control-unavailable"><i class="bx bx-lock-alt"></i><span>Heroku deployment history is private</span><small>Current release metadata remains visible above.</small></div>'; }
      else deployments.innerHTML = records.map((record) => `<a href="${escapeHtml(record.creator.html_url)}" target="_blank" rel="noopener"><i class="bx bx-check-circle"></i><span>${escapeHtml(record.environment || 'production')}</span><strong>${escapeHtml(record.sha.slice(0, 7))}</strong></a>`).join('');
    } catch (_error) { deployments.innerHTML = '<div class="control-unavailable"><i class="bx bx-lock-alt"></i><span>Deployment history unavailable</span><small>No privileged API credentials are exposed.</small></div>'; }
    refreshedAt = Date.now(); updateClock();
  };
  const refreshAll = () => { refreshBrowserPerformance(); refreshProviderTelemetry(); refreshGithub(); };
  root.querySelector('[data-control-refresh-button]').addEventListener('click', refreshAll); window.setTimeout(refreshBrowserPerformance, 0); refreshProviderTelemetry(); refreshGithub();
};

const setupSandGame = () => {
  const root = document.querySelector('[data-sand-game]');
  if (!root) return;
  const canvas = root.querySelector('[data-sand-canvas]');
  const context = canvas.getContext('2d');
  const colors = { sand: ['#f9e71c', '#e6b84d', '#ffce6a'], water: ['#42d9c8', '#3b82f6', '#55b7e8'], stone: ['#8b7fa7', '#655b80', '#aaa0c3'] };
  let columns; let rows; let grid; let next; let cellSize; let material = 'sand'; let brush = 4; let drawing = false; let paused = matchMedia('(prefers-reduced-motion: reduce)').matches; let frame; let previous = 0;
  const emptyGrid = () => Array.from({ length: rows }, () => new Uint8Array(columns));
  const resize = () => {
    const bounds = canvas.getBoundingClientRect(); const ratio = Math.min(devicePixelRatio || 1, 2);
    cellSize = bounds.width < 600 ? 5 : 6; columns = Math.floor(bounds.width / cellSize); rows = Math.floor(bounds.height / cellSize);
    canvas.width = bounds.width * ratio; canvas.height = bounds.height * ratio; context.setTransform(ratio, 0, 0, ratio, 0, 0); grid = emptyGrid(); next = emptyGrid();
    for (let x = Math.floor(columns * 0.32); x < Math.floor(columns * 0.68); x += 1) grid[Math.floor(rows * 0.72)][x] = 3;
    for (let index = 0; index < Math.min(260, columns * 3); index += 1) { const x = Math.floor(columns * 0.18 + Math.random() * columns * 0.25); const y = Math.floor(rows * 0.08 + Math.random() * rows * 0.2); grid[y][x] = 1; }
    for (let index = 0; index < Math.min(180, columns * 2); index += 1) { const x = Math.floor(columns * 0.62 + Math.random() * columns * 0.2); const y = Math.floor(rows * 0.12 + Math.random() * rows * 0.18); grid[y][x] = 2; }
  };
  const paint = (event) => {
    const bounds = canvas.getBoundingClientRect(); const cx = Math.floor((event.clientX - bounds.left) / cellSize); const cy = Math.floor((event.clientY - bounds.top) / cellSize); const value = { erase: 0, sand: 1, water: 2, stone: 3 }[material];
    for (let y = -brush; y <= brush; y += 1) for (let x = -brush; x <= brush; x += 1) if (x * x + y * y <= brush * brush && grid[cy + y]?.[cx + x] !== undefined && (value === 0 || Math.random() > 0.18)) grid[cy + y][cx + x] = value;
  };
  const move = (x, y, nx, ny) => { next[ny][nx] = grid[y][x]; next[y][x] = 0; };
  const update = () => {
    next = grid.map((row) => Uint8Array.from(row));
    for (let y = rows - 2; y >= 0; y -= 1) {
      const leftFirst = Math.random() > 0.5;
      for (let offset = 0; offset < columns; offset += 1) {
        const x = leftFirst ? offset : columns - 1 - offset; const value = grid[y][x]; if (!value || value === 3 || next[y][x] === 0) continue;
        if (value === 1) {
          if (grid[y + 1][x] === 0) move(x, y, x, y + 1);
          else { const directions = Math.random() > 0.5 ? [-1, 1] : [1, -1]; const dx = directions.find((direction) => grid[y + 1]?.[x + direction] === 0); if (dx) move(x, y, x + dx, y + 1); }
        } else if (value === 2) {
          if (grid[y + 1][x] === 0) move(x, y, x, y + 1);
          else { const directions = Math.random() > 0.5 ? [-1, 1] : [1, -1]; const dx = directions.find((direction) => grid[y]?.[x + direction] === 0); if (dx) move(x, y, x + dx, y); }
        }
      }
    }
    grid = next;
  };
  const draw = () => { context.fillStyle = '#100b25'; context.fillRect(0, 0, canvas.width, canvas.height); for (let y = 0; y < rows; y += 1) for (let x = 0; x < columns; x += 1) if (grid[y][x]) { const palette = colors[{ 1: 'sand', 2: 'water', 3: 'stone' }[grid[y][x]]]; context.fillStyle = palette[(x * 7 + y * 3) % palette.length]; context.fillRect(x * cellSize, y * cellSize, cellSize + 0.25, cellSize + 0.25); } };
  const animate = (time) => { if (!paused && time - previous > 28) { update(); draw(); previous = time; } frame = requestAnimationFrame(animate); };
  root.querySelectorAll('[data-sand-material]').forEach((button) => button.addEventListener('click', () => { material = button.dataset.sandMaterial; root.querySelectorAll('[data-sand-material]').forEach((item) => { const selected = item === button; item.classList.toggle('is-active', selected); item.setAttribute('aria-pressed', selected.toString()); }); }));
  root.querySelector('[data-sand-brush]').addEventListener('input', (event) => { brush = Number(event.target.value); root.querySelector('[data-sand-output]').textContent = brush; });
  root.querySelector('[data-sand-action="clear"]').addEventListener('click', () => { grid = emptyGrid(); draw(); });
  const pause = root.querySelector('[data-sand-action="pause"]'); const updatePause = () => { pause.setAttribute('aria-pressed', paused.toString()); pause.querySelector('i').className = paused ? 'bx bx-play' : 'bx bx-pause'; pause.querySelector('span').textContent = paused ? 'Play' : 'Pause'; };
  pause.addEventListener('click', () => { paused = !paused; updatePause(); }); updatePause();
  canvas.addEventListener('pointerdown', (event) => { drawing = true; canvas.setPointerCapture(event.pointerId); paint(event); draw(); }); canvas.addEventListener('pointermove', (event) => { if (drawing) { paint(event); draw(); } }); canvas.addEventListener('pointerup', () => { drawing = false; });
  window.addEventListener('resize', resize); resize(); draw(); frame = requestAnimationFrame(animate);
};

const setupLifeGame = () => {
  const root = document.querySelector('[data-life-game]'); if (!root) return;
  const canvas = root.querySelector('[data-life-canvas]'); const context = canvas.getContext('2d');
  let columns; let rows; let grid; let cellSize; let playing = false; let generation = 0; let speed = 8; let drawing = false; let paintValue = 1; let frame; let previous = 0;
  const blank = () => Array.from({ length: rows }, () => new Uint8Array(columns));
  const resize = () => { const bounds = canvas.getBoundingClientRect(); const ratio = Math.min(devicePixelRatio || 1, 2); cellSize = bounds.width < 600 ? 9 : 12; columns = Math.floor(bounds.width / cellSize); rows = Math.floor(bounds.height / cellSize); canvas.width = bounds.width * ratio; canvas.height = bounds.height * ratio; context.setTransform(ratio, 0, 0, ratio, 0, 0); grid = blank(); generation = 0; draw(); };
  const draw = () => { context.fillStyle = '#100b25'; context.fillRect(0, 0, canvas.width, canvas.height); context.strokeStyle = 'rgba(153,140,207,.10)'; context.lineWidth = 0.5; for (let x = 0; x <= columns; x += 1) { context.beginPath(); context.moveTo(x * cellSize, 0); context.lineTo(x * cellSize, rows * cellSize); context.stroke(); } for (let y = 0; y <= rows; y += 1) { context.beginPath(); context.moveTo(0, y * cellSize); context.lineTo(columns * cellSize, y * cellSize); context.stroke(); } for (let y = 0; y < rows; y += 1) for (let x = 0; x < columns; x += 1) if (grid[y][x]) { context.fillStyle = (x + y + generation) % 5 ? '#b29cff' : '#f9e71c'; context.fillRect(x * cellSize + 1, y * cellSize + 1, cellSize - 2, cellSize - 2); } root.querySelector('[data-life-generation]').textContent = generation; };
  const step = () => { const next = blank(); for (let y = 0; y < rows; y += 1) for (let x = 0; x < columns; x += 1) { let neighbors = 0; for (let dy = -1; dy <= 1; dy += 1) for (let dx = -1; dx <= 1; dx += 1) if (dx || dy) neighbors += grid[(y + dy + rows) % rows][(x + dx + columns) % columns]; next[y][x] = neighbors === 3 || (grid[y][x] && neighbors === 2) ? 1 : 0; } grid = next; generation += 1; draw(); };
  const paint = (event) => { const bounds = canvas.getBoundingClientRect(); const x = Math.floor((event.clientX - bounds.left) / cellSize); const y = Math.floor((event.clientY - bounds.top) / cellSize); if (grid[y]?.[x] !== undefined) { grid[y][x] = paintValue; draw(); } };
  const seed = (pattern) => { grid = blank(); generation = 0; const cx = Math.floor(columns / 2); const cy = Math.floor(rows / 2); if (pattern === 'random') { for (let y = 0; y < rows; y += 1) for (let x = 0; x < columns; x += 1) grid[y][x] = Math.random() < 0.27 ? 1 : 0; } else if (pattern !== 'clear') { const points = pattern === 'glider' ? [[1,0],[2,1],[0,2],[1,2],[2,2]] : [[2,0],[3,0],[4,0],[8,0],[9,0],[10,0],[0,2],[5,2],[7,2],[12,2],[0,3],[5,3],[7,3],[12,3],[0,4],[5,4],[7,4],[12,4],[2,5],[3,5],[4,5],[8,5],[9,5],[10,5],[2,7],[3,7],[4,7],[8,7],[9,7],[10,7],[0,8],[5,8],[7,8],[12,8],[0,9],[5,9],[7,9],[12,9],[0,10],[5,10],[7,10],[12,10],[2,12],[3,12],[4,12],[8,12],[9,12],[10,12]]; points.forEach(([x,y]) => { if (grid[cy + y - 6]?.[cx + x - 6] !== undefined) grid[cy + y - 6][cx + x - 6] = 1; }); } draw(); };
  const animate = (time) => { if (playing && time - previous > 1000 / speed) { step(); previous = time; } frame = requestAnimationFrame(animate); };
  root.querySelectorAll('[data-life-preset]').forEach((button) => button.addEventListener('click', () => seed(button.dataset.lifePreset)));
  root.querySelector('[data-life-speed]').addEventListener('input', (event) => { speed = Number(event.target.value); root.querySelector('[data-life-output]').textContent = speed; }); root.querySelector('[data-life-action="step"]').addEventListener('click', step); root.querySelector('[data-life-action="clear"]').addEventListener('click', () => seed('clear'));
  const play = root.querySelector('[data-life-action="play"]'); play.addEventListener('click', () => { playing = !playing; play.setAttribute('aria-pressed', playing.toString()); play.querySelector('i').className = playing ? 'bx bx-pause' : 'bx bx-play'; play.querySelector('span').textContent = playing ? 'Pause' : 'Play'; });
  canvas.addEventListener('pointerdown', (event) => { const bounds = canvas.getBoundingClientRect(); const x = Math.floor((event.clientX - bounds.left) / cellSize); const y = Math.floor((event.clientY - bounds.top) / cellSize); paintValue = grid[y]?.[x] ? 0 : 1; drawing = true; canvas.setPointerCapture(event.pointerId); paint(event); }); canvas.addEventListener('pointermove', (event) => { if (drawing) paint(event); }); canvas.addEventListener('pointerup', () => { drawing = false; });
  window.addEventListener('resize', resize); resize(); seed('glider'); frame = requestAnimationFrame(animate);
};

document.addEventListener('turbo:load', () => { setupSignalGarden(); setupRidesSimulation(); setupSandGame(); setupLifeGame(); setupPhotoConstellation(); setupPhotographersEye(); setupPhotoTimeline(); setupSiteControlRoom(); });
