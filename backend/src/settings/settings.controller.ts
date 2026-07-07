import { Controller, Get, Patch, Body, UseGuards } from '@nestjs/common';
import { SettingsService } from './settings.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { UpdateSettingsDto } from './dto/update-settings.dto';

@Controller('settings')
@UseGuards(JwtAuthGuard)
export class SettingsController {
  constructor(private settingsService: SettingsService) {}

  @Get()
  getSettings(@CurrentUser() user: any) {
    return this.settingsService.getByUserId(user.id);
  }

  @Patch()
  updateSettings(@CurrentUser() user: any, @Body() dto: UpdateSettingsDto) {
    return this.settingsService.update(user.id, dto);
  }
}
