const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
async function main() {
  const user = await prisma.user.findUnique({ where: { email: 'demo@test.com' } });
  if (!user) { console.log('User not found'); return; }
  await prisma.subscription.upsert({
    where: { userId: user.id },
    update: {},
    create: { userId: user.id, tier: 'GROWTH', minutesLimit: 500, status: 'active' }
  });
  await prisma.businessSettings.upsert({
    where: { userId: user.id },
    update: {},
    create: { userId: user.id, businessName: 'Test Business', aiTone: 'friendly', timezone: 'Africa/Lagos' }
  });
  console.log('Demo user ready:', user.email);
}
main().catch(console.error).finally(() => prisma.$disconnect());
