/**
 * Enhanced Strapi Seed Script with Diagnostics
 */

const STRAPI_URL = process.env.STRAPI_URL || 'http://localhost:1337';
const API_TOKEN = process.env.STRAPI_API_TOKEN || '42f58c573e5ed14875826c89c7e4a9a5fbbe89c01a830c6c15a30f12ee115efc3cfd88dba56cffa485fd7045a19c83aaf7f6b1de9b3b51235289ea492c1babe666db3f787574e1eeb0576a43b1485d8b1cbce4f2113b5c036976053838775be4154a0e5d299f973210175dec233902250ef634b635edb84131ad25f11a6d809a';

const log = {
  info: (msg) => console.log('\x1b[36m%s\x1b[0m', `ℹ ${msg}`),
  success: (msg) => console.log('\x1b[32m%s\x1b[0m', `✓ ${msg}`),
  error: (msg) => console.log('\x1b[31m%s\x1b[0m', `✗ ${msg}`),
  warn: (msg) => console.log('\x1b[33m%s\x1b[0m', `⚠ ${msg}`),
  debug: (msg) => console.log('\x1b[35m%s\x1b[0m', `🐛 ${msg}`),
};

// Step 1: Diagnostics
async function runDiagnostics() {
  log.info('Running diagnostics...\n');

  // Check Strapi URL
  log.debug(`Strapi URL: ${STRAPI_URL}`);
  
  // Check API Token
  if (!API_TOKEN || API_TOKEN === '') {
    log.error('API_TOKEN is empty!');
    log.warn('You need to provide your JWT token. Choose one of these methods:\n');
    log.info('Method 1: Set environment variable:');
    console.log('   SET STRAPI_API_TOKEN=your-jwt-token-here (Windows)');
    console.log('   export STRAPI_API_TOKEN=your-jwt-token-here (Mac/Linux)\n');
    log.info('Method 2: Edit scripts/seed.js and set API_TOKEN directly\n');
    log.info('To get your JWT token:');
    console.log('   1. Go to http://localhost:1337/admin');
    console.log('   2. Open DevTools (F12)');
    console.log('   3. Go to Application > LocalStorage');
    console.log('   4. Find "jwtToken" and copy its value\n');
    return false;
  }

  // Check if Strapi is running
  try {
    log.info('Checking if Strapi is running...');
    const healthResponse = await fetch(`${STRAPI_URL}/admin/init`, {
      method: 'GET',
      headers: { 'Authorization': `Bearer ${API_TOKEN}` },
    });

    if (healthResponse.ok) {
      log.success('✓ Strapi is running and API is accessible');
      return true;
    } else if (healthResponse.status === 401) {
      log.error('Authentication failed - JWT token is invalid or expired');
      log.warn('Please get a fresh JWT token from http://localhost:1337/admin');
      return false;
    } else {
      log.error(`Strapi returned: ${healthResponse.status}`);
      return false;
    }
  } catch (error) {
    log.error(`Cannot connect to Strapi at ${STRAPI_URL}`);
    log.error(`Error: ${error.message}`);
    log.warn('\nMake sure Strapi is running:');
    console.log('   npm run develop\n');
    return false;
  }
}

// Step 2: Seed data
async function strapiRequest(endpoint, method = 'GET', data = null) {
  try {
    const options = {
      method,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_TOKEN}`,
      },
    };

    if (data) {
      options.body = JSON.stringify(data);
    }

    const response = await fetch(`${STRAPI_URL}/api${endpoint}`, options);

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`${response.status}: ${errorText}`);
    }

    return await response.json();
  } catch (error) {
    throw error;
  }
}

async function seedCities() {
  log.info('Creating Cities...');
  const citiesData = [
    { name: 'Lisboa', slug: 'lisboa', image_url: 'https://images.unsplash.com/photo-1555881286-ac550fe6aceb?w=800', description: 'A capital e a maior cidade de Portugal', is_published: true },
    { name: 'Porto', slug: 'porto', image_url: 'https://images.unsplash.com/photo-1548681528-6a846cf386ad?w=800', description: 'Cidade histórica no norte de Portugal', is_published: true },
    { name: 'Coimbra', slug: 'coimbra', image_url: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800', description: 'Cidade universitária histórica', is_published: true },
    { name: 'Faro', slug: 'faro', image_url: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800', description: 'Capital do Algarve', is_published: true },
    { name: 'Aveiro', slug: 'aveiro', image_url: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800', description: 'Veneza de Portugal', is_published: true },
  ];

  const cities = {};
  for (const city of citiesData) {
    try {
      const response = await strapiRequest('/cities', 'POST', { data: city });
      cities[response.data.attributes.slug] = response.data.id;
      log.success(`Created city: ${response.data.attributes.name}`);
    } catch (error) {
      log.error(`Failed to create city ${city.name}: ${error.message}`);
    }
  }

  return cities;
}

async function main() {
  try {
    // Run diagnostics first
    const isReady = await runDiagnostics();
    
    if (!isReady) {
      log.error('\n❌ Cannot proceed with seeding. Fix the issues above first.\n');
      process.exit(1);
    }

    log.success('\n✓ All checks passed!\n');

    // Proceed with seeding
    const cities = await seedCities();

    log.success(`\n✓ Seeding complete! Created ${Object.keys(cities).length} cities`);

  } catch (error) {
    log.error(`\nFatal error: ${error.message}`);
    log.debug(error.stack);
    process.exit(1);
  }
}

main();