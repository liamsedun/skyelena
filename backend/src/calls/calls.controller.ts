import { Controller, Get, Param, Patch, Body, UseGuards } from '@nestjs/common';
import { CallsService } from './calls.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { UpdateCallDto } from './dto/update-call.dto';

@Controller('calls')
@UseGuards(JwtAuthGuard)
export class CallsController {
  constructor(private callsService: CallsService) {}

  @Get()
  findAll(@CurrentUser() user: any) {
    return this.callsService.findAll(user.id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.callsService.findById(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateCallDto) {
    return this.callsService.update(id, dto);
  }
}
