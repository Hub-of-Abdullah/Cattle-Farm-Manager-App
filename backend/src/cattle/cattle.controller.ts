import {
  Controller, Get, Post, Patch, Delete,
  Param, Body, Query, ParseIntPipe, UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiQuery, ApiTags } from '@nestjs/swagger';
import { CattleService } from './cattle.service';
import { CreateCattleDto } from './dto/create-cattle.dto';
import { UpdateCattleDto } from './dto/update-cattle.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@ApiTags('Cattle')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('cattle')
export class CattleController {
  constructor(private readonly service: CattleService) {}

  @Get()
  @ApiQuery({ name: 'ownerId', required: false, type: Number })
  @ApiQuery({ name: 'isSold', required: false, type: Boolean })
  findAll(@Query('ownerId') ownerId?: number, @Query('isSold') isSold?: boolean) {
    return this.service.findAll(ownerId, isSold);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.service.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateCattleDto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateCattleDto) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    await this.service.remove(id);
    return { message: 'Cattle deleted successfully' };
  }
}
