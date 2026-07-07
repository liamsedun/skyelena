import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { BookingsService } from './bookings.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateBookingDto, UpdateBookingDto } from './dto/create-booking.dto';

@Controller('bookings')
@UseGuards(JwtAuthGuard)
export class BookingsController {
  constructor(private bookingsService: BookingsService) {}

  @Get()
  findAll(@CurrentUser() user: any) {
    return this.bookingsService.findAll(user.id);
  }

  @Get('upcoming')
  findUpcoming(@CurrentUser() user: any) {
    return this.bookingsService.findUpcoming(user.id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.bookingsService.findById(id);
  }

  @Post()
  create(@CurrentUser() user: any, @Body() dto: CreateBookingDto) {
    return this.bookingsService.create(user.id, dto);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateBookingDto) {
    return this.bookingsService.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.bookingsService.remove(id);
  }
}
