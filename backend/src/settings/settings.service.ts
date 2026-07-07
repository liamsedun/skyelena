import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateSettingsDto } from './dto/update-settings.dto';

@Injectable()
export class SettingsService {
  constructor(private prisma: PrismaService) {}

  async getByUserId(userId: string) {
    let settings = await this.prisma.businessSettings.findUnique({
      where: { userId },
    });

    if (!settings) {
      settings = await this.prisma.businessSettings.create({
        data: { userId },
      });
    }

    return settings;
  }

  async update(userId: string, dto: UpdateSettingsDto) {
    const settings = await this.prisma.businessSettings.findUnique({
      where: { userId },
    });

    if (!settings) {
      throw new NotFoundException('Settings not found');
    }

    return this.prisma.businessSettings.update({
      where: { userId },
      data: dto,
    });
  }
}
